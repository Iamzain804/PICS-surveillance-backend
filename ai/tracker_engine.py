import os
import sys
import time
import cv2
import warnings
warnings.filterwarnings("ignore")
import re
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional, Set, Tuple
from ultralytics import YOLO

# Auto-resolve project root in sys.path when script is executed directly from subfolder
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..")))

try:
    from ai.matcher import FaceMatcher
    from ai.gpu_decoder import NVDECGPUVideoDecoder
    from database.database import save_video_processing_results
    from ai.ocr_extractor import extract_video_metadata_from_frame, get_shared_ocr_reader
except ImportError:
    try:
        from ai.matcher import FaceMatcher
        from ai.gpu_decoder import NVDECGPUVideoDecoder
        from core.database import save_video_processing_results
        from ai.ocr_extractor import extract_video_metadata_from_frame, get_shared_ocr_reader
    except ImportError:
        from matcher import FaceMatcher
        from gpu_decoder import NVDECGPUVideoDecoder
        from ocr_extractor import extract_video_metadata_from_frame, get_shared_ocr_reader
        save_video_processing_results = None

def compute_bbox_iou(box1: np.ndarray, box2: List[int]) -> float:
    """
    Computes Intersection over Union (IoU) of two bounding boxes [x1, y1, x2, y2].
    """
    x1 = max(box1[0], box2[0])
    y1 = max(box1[1], box2[1])
    x2 = min(box1[2], box2[2])
    y2 = min(box1[3], box2[3])

    inter_width = max(0, x2 - x1)
    inter_height = max(0, y2 - y1)
    inter_area = inter_width * inter_height

    if inter_area == 0:
        return 0.0

    box1_area = (box1[2] - box1[0]) * (box1[3] - box1[1])
    box2_area = (box2[2] - box2[0]) * (box2[3] - box2[1])
    union_area = float(box1_area + box2_area - inter_area)

    return inter_area / union_area if union_area > 0 else 0.0

# extract_start_timestamp_from_frame was removed and replaced by ai.ocr_extractor.extract_video_metadata_from_frame

def extract_appearance_feature(crop_bgr: np.ndarray) -> Optional[np.ndarray]:
    """
    Extracts a normalized 48-bin HSV spatial color-histogram appearance feature vector 
    for zero-cost Re-ID matching when face is obscured or turned away.
    """
    if crop_bgr is None or crop_bgr.size == 0:
        return None
    try:
        resized = cv2.resize(crop_bgr, (64, 128))
        hsv = cv2.cvtColor(resized, cv2.COLOR_BGR2HSV)
        hist = cv2.calcHist([hsv], [0, 1, 2], None, [8, 8, 4], [0, 180, 0, 256, 0, 256])
        hist = cv2.normalize(hist, hist).flatten()
        return hist.astype(np.float32)
    except Exception:
        return None

def compute_appearance_similarity(feat1: Optional[np.ndarray], feat2: Optional[np.ndarray]) -> float:
    if feat1 is None or feat2 is None:
        return 0.0
    try:
        return float(cv2.compareHist(feat1, feat2, cv2.HISTCMP_CORREL))
    except Exception:
        return 0.0

def format_time_str(start_dt: Optional[datetime], frame_idx: int, fps: float) -> str:
    fps_valid = max(fps, 1.0)
    total_sec = int(frame_idx / fps_valid)
    hrs = total_sec // 3600
    mins = (total_sec % 3600) // 60
    secs = total_sec % 60
    rel_time = f"{hrs:02d}:{mins:02d}:{secs:02d}"
    
    if start_dt:
        curr_dt = start_dt + timedelta(seconds=(frame_idx / fps_valid))
        date_str = curr_dt.strftime("%d-%m-%Y %H:%M:%S")
        return f"{rel_time} ({date_str})"
    return rel_time

class AIProcessPipeline:
    def __init__(self, yolo_model_name: Optional[str] = None, pkl_path: Optional[str] = None):
        if yolo_model_name is None:
            engine_file = os.path.join(os.path.dirname(__file__), "..", "models", "yolov8n.engine")
            pt_file = os.path.join(os.path.dirname(__file__), "..", "models", "yolov8n.pt")
            if os.path.exists(engine_file):
                yolo_model_name = engine_file
            elif os.path.exists(pt_file):
                yolo_model_name = pt_file
            else:
                yolo_model_name = "models/yolov8n.pt"

        if pkl_path is None:
            default_path = os.path.join(os.path.dirname(__file__), "encoding", "encodings.pkl")
            fallback_path = os.path.join(os.path.dirname(__file__), "encodings.pkl")
            pkl_path = default_path if os.path.exists(default_path) else fallback_path
        print(f"[AI PIPELINE] Initializing YOLO Engine ({os.path.basename(yolo_model_name)}) with NVIDIA NVDEC GPU Video Decoder...")
        self.yolo_model = YOLO(yolo_model_name)
        self.face_matcher = FaceMatcher(pkl_path=pkl_path)
        self.ocr_reader = get_shared_ocr_reader()
        
        # Master Registry: Key = master_track_id -> Consolidated Master Track Record
        self.master_registry: Dict[int, Dict[str, Any]] = {}
        # Mapping: raw_track_id -> master_track_id
        self.raw_to_master_map: Dict[int, int] = {}
        # Mapping: person_name -> master_track_id for Authorized persons
        self.identity_master_map: Dict[str, int] = {}
        # Set of event logs already printed to ensure EXACTLY ONCE printing
        self.logged_events: Set[str] = set()
        # Mapping: person_name -> last frame index printed for 20-sec cooldown
        self.last_logged_frames: Dict[str, int] = {}

    def _find_matching_unauthorized_master(
        self, 
        current_bbox: np.ndarray, 
        current_frame: int, 
        exclude_master_ids: Set[int],
        current_crop: Optional[np.ndarray] = None,
        max_dist_px: float = 220.0, 
        max_frame_gap: int = 500
    ) -> Optional[int]:
        """
        Matured Multi-Factor Re-ID Engine.
        Combines:
        1. Color-spatial appearance histogram similarity (HSV correlation)
        2. Velocity motion prediction (Kalman-like trajectory estimation)
        3. Bounding box IoU overlap
        """
        cx = (current_bbox[0] + current_bbox[2]) / 2.0
        cy = (current_bbox[1] + current_bbox[3]) / 2.0
        curr_center = np.array([cx, cy])
        curr_feat = extract_appearance_feature(current_crop) if current_crop is not None else None
        
        best_master_id = None
        best_match_score = -1.0

        for m_id, state in self.master_registry.items():
            if m_id in exclude_master_ids:
                continue

            if state.get("status") in ["Unauthorized", "Pending"]:
                last_seen = state.get("last_frame_seen", 0)
                frame_diff = current_frame - last_seen
                if 1 <= frame_diff <= max_frame_gap:
                    last_bbox = state.get("last_bbox")
                    if last_bbox is not None:
                        # 1. IoU Overlap Score
                        iou_score = compute_bbox_iou(current_bbox, last_bbox)

                        # 2. Motion Velocity Prediction
                        lcx = (last_bbox[0] + last_bbox[2]) / 2.0
                        lcy = (last_bbox[1] + last_bbox[3]) / 2.0
                        velocity = state.get("velocity", [0.0, 0.0])
                        
                        pred_cx = lcx + velocity[0] * frame_diff
                        pred_cy = lcy + velocity[1] * frame_diff
                        pred_center = np.array([pred_cx, pred_cy])
                        
                        dist_pred = float(np.linalg.norm(curr_center - pred_center))
                        dist_score = max(0.0, 1.0 - (dist_pred / max_dist_px))

                        # 3. Appearance Feature Similarity
                        master_feat = state.get("appearance_feature")
                        app_score = max(0.0, compute_appearance_similarity(curr_feat, master_feat)) if (curr_feat is not None and master_feat is not None) else 0.0

                        # Fused Multi-Factor Score: Appearance (40%) + IoU (35%) + Motion Distance (25%)
                        total_score = (0.40 * app_score) + (0.35 * iou_score) + (0.25 * dist_score)

                        if total_score > 0.28 and total_score > best_match_score:
                            best_match_score = total_score
                            best_master_id = m_id

        return best_master_id

    def process_video(
        self, 
        video_path: str, 
        conf_threshold: float = 0.35, 
        max_frames: Optional[int] = None, 
        show_live: bool = True,
        empty_frame_skip: int = 10,
        recheck_interval_frames: int = 25,   # Re-check face rec every 1 sec (~25 frames)
        max_observation_sec: float = 30.0,   # Watch for up to 30 seconds max
        exit_threshold_frames: int = 45       # Exit screen threshold (~1.5 sec)
    ) -> Dict[str, Any]:
        if not os.path.exists(video_path):
            raise FileNotFoundError(f"Video file not found: {video_path}")

        video_name = os.path.basename(video_path)
        
        # ⚡ NVDEC Hardware GPU Video Decoder ⚡
        decoder = NVDECGPUVideoDecoder(video_path)
        fps = decoder.fps or 25.0
        max_observation_frames = int(fps * max_observation_sec)
        cooldown_frames = int(fps * 20.0)

        self.master_registry.clear()
        self.raw_to_master_map.clear()
        self.identity_master_map.clear()
        self.logged_events.clear()
        self.last_logged_frames.clear()

        frame_idx = 0
        in_person_scene = False
        start_dt: Optional[datetime] = None
        video_start_str: Optional[str] = None
        ocr_attempted = False
        start_proc_time = time.time()

        print(f"[AI PIPELINE] Processing Video with NVDEC GPU Decoder: {video_name}")

        try:
            while True:
                if max_frames and frame_idx >= max_frames:
                    break

                # Dynamic Frame Skip when no person is present
                if not in_person_scene and empty_frame_skip > 1:
                    for _ in range(empty_frame_skip - 1):
                        decoder.grab()
                        frame_idx += 1

                ret, frame = decoder.read()
                if not ret or frame is None:
                    break

                # 🎯 Extract Real-World OSD Timestamp from 1st Frame via OCR
                if start_dt is None and not ocr_attempted:
                    ocr_attempted = True
                    dt_val, video_start_str, _ = extract_video_metadata_from_frame(frame, self.ocr_reader, filename=video_name)
                    if video_start_str and dt_val:
                        start_dt = dt_val
                        print(f"[VIDEO OCR TIMESTAMP] 🕒 Video Start Time Extracted: {video_start_str}")
                    else:
                        start_dt = datetime.now()
                        print(f"[VIDEO OCR TIMESTAMP] ℹ️ No OSD watermark text found on video. Using frame timestamp offsets.")

                h, w, _ = frame.shape

                # YOLO Detection with ByteTrack Tracking (Class 0 = Person)
                results = self.yolo_model.track(
                    source=frame,
                    persist=True,
                    classes=[0],
                    conf=conf_threshold,
                    tracker="bytetrack.yaml",
                    verbose=False
                )

                person_detected = False
                active_master_ids_in_frame: Set[int] = set()

                if results and len(results) > 0 and results[0].boxes is not None:
                    boxes = results[0].boxes
                    
                    if boxes.is_track and len(boxes) > 0:
                        person_detected = True
                        raw_track_ids = boxes.id.int().cpu().tolist()
                        xyxy_list = boxes.xyxy.cpu().numpy()

                        # Step 1: Process active persons in current frame
                        for raw_id, bbox in zip(raw_track_ids, xyxy_list):
                            x1, y1, x2, y2 = map(int, bbox)
                            x1, y1 = max(0, x1), max(0, y1)
                            x2, y2 = min(w, x2), min(h, y2)

                            person_crop = frame[y1:y2, x1:x2]

                            # Determine Master ID for raw_id
                            if raw_id in self.raw_to_master_map:
                                master_id = self.raw_to_master_map[raw_id]
                            else:
                                master_id = raw_id
                                self.raw_to_master_map[raw_id] = master_id

                            master_state = self.master_registry.get(master_id)

                            # If master is not finalized Authorized, test Face Rec
                            if not master_state or not master_state["finalized"]:
                                first_detected = master_state.get("first_frame_detected", frame_idx) if master_state else frame_idx
                                tracked_duration = frame_idx - first_detected
                                last_attempt = master_state.get("last_attempt_frame", -recheck_interval_frames) if master_state else -recheck_interval_frames

                                if frame_idx - last_attempt >= recheck_interval_frames:
                                    is_auth, person_name, person_id, conf = self.face_matcher.recognize_crop(person_crop)

                                    if is_auth:
                                        status = "Authorized"
                                        finalized = True

                                        # Same Authorized Person -> Merge to Existing Master Track ID
                                        if person_name in self.identity_master_map:
                                            target_master_id = self.identity_master_map[person_name]
                                            if target_master_id != master_id:
                                                self.raw_to_master_map[raw_id] = target_master_id
                                                if master_id in self.master_registry:
                                                    del self.master_registry[master_id]
                                                master_id = target_master_id
                                        else:
                                            self.identity_master_map[person_name] = master_id

                                        target = self.master_registry.get(master_id, {})
                                        self.master_registry[master_id] = {
                                            "track_id": master_id,
                                            "master_track_id": master_id,
                                            "status": "Authorized",
                                            "person_name": person_name,
                                            "person_id": person_id,
                                            "confidence": max(conf, target.get("confidence", 0.0)),
                                            "first_frame_detected": min(first_detected, target.get("first_frame_detected", first_detected)),
                                            "last_frame_seen": frame_idx,
                                            "last_bbox": [x1, y1, x2, y2],
                                            "total_hits": target.get("total_hits", 0) + 1,
                                            "last_attempt_frame": frame_idx,
                                            "finalized": True,
                                            "exited_screen": False
                                        }

                                        # 🎯 PRINT LOG IF NEW OR IF RE-ENTERING AFTER 20-SEC COOLDOWN (500 frames)
                                        last_log_frame = self.last_logged_frames.get(person_name, -cooldown_frames - 1)
                                        if frame_idx - last_log_frame > cooldown_frames:
                                            self.last_logged_frames[person_name] = frame_idx
                                            sys_time_str = datetime.now().strftime("%H:%M:%S")
                                            time_tag = format_time_str(start_dt, frame_idx, fps)
                                            elapsed_wall_sec = max(time.time() - start_proc_time, 0.001)
                                            current_proc_fps = frame_idx / elapsed_wall_sec
                                            speed_mult = current_proc_fps / max(fps, 1.0)
                                            print(f"[AUTHORIZED LOG] Person: {person_name} (Master Track #{master_id} | Sys Time: {sys_time_str} | Video Time: {time_tag} | Frame {frame_idx} | Proc Speed: {current_proc_fps:.1f} FPS / {speed_mult:.1f}x)")

                                    else:
                                        # Not matched yet
                                        if tracked_duration >= max_observation_frames:
                                            status = "Unauthorized"
                                            person_name = "Unauthorized"
                                            finalized = True
                                            
                                            log_key = f"unauth_obs_{master_id}"
                                            if log_key not in self.logged_events:
                                                self.logged_events.add(log_key)
                                                sys_time_str = datetime.now().strftime("%H:%M:%S")
                                                time_tag = format_time_str(start_dt, frame_idx, fps)
                                                elapsed_wall_sec = max(time.time() - start_proc_time, 0.001)
                                                current_proc_fps = frame_idx / elapsed_wall_sec
                                                speed_mult = current_proc_fps / max(fps, 1.0)
                                                print(f"[UNAUTHORIZED LOG] Master Track #{master_id} observed for {max_observation_sec:.0f}s without match -> Finalized as Unauthorized! (Sys Time: {sys_time_str} | Video Time: {time_tag} | Frame {frame_idx} | Proc Speed: {current_proc_fps:.1f} FPS / {speed_mult:.1f}x)")
                                        else:
                                            status = "Pending"
                                            finalized = False
                                            
                                            # Multi-Factor Re-ID for lost unauthorized/pending master
                                            matching_unauth_master = self._find_matching_unauthorized_master(
                                                current_bbox=np.array([x1, y1, x2, y2]),
                                                current_frame=frame_idx,
                                                exclude_master_ids=active_master_ids_in_frame,
                                                current_crop=person_crop
                                            )
                                            if matching_unauth_master is not None and matching_unauth_master != master_id:
                                                old_m = master_id
                                                master_id = matching_unauth_master
                                                self.raw_to_master_map[raw_id] = master_id
                                                if old_m in self.master_registry and old_m != master_id:
                                                    del self.master_registry[old_m]

                                        target = self.master_registry.get(master_id, {})
                                        
                                        # Calculate Motion Velocity & Extract Appearance Feature
                                        curr_center = [(x1 + x2) / 2.0, (y1 + y2) / 2.0]
                                        old_center = target.get("last_center")
                                        old_frame = target.get("last_frame_seen")
                                        if old_center and old_frame:
                                            fdiff = max(1, frame_idx - old_frame)
                                            vx = (curr_center[0] - old_center[0]) / fdiff
                                            vy = (curr_center[1] - old_center[1]) / fdiff
                                        else:
                                            vx, vy = 0.0, 0.0

                                        app_feat = extract_appearance_feature(person_crop)
                                        if app_feat is None:
                                            app_feat = target.get("appearance_feature")

                                        self.master_registry[master_id] = {
                                            "track_id": master_id,
                                            "master_track_id": master_id,
                                            "status": status,
                                            "person_name": person_name,
                                            "person_id": person_id if is_auth else None,
                                            "confidence": conf,
                                            "first_frame_detected": min(first_detected, target.get("first_frame_detected", first_detected)),
                                            "last_frame_seen": frame_idx,
                                            "last_bbox": [x1, y1, x2, y2],
                                            "last_center": curr_center,
                                            "velocity": [vx, vy],
                                            "appearance_feature": app_feat,
                                            "total_hits": target.get("total_hits", 0) + 1,
                                            "last_attempt_frame": frame_idx,
                                            "finalized": finalized,
                                            "exited_screen": False
                                        }

                                    active_master_ids_in_frame.add(master_id)
                                else:
                                    active_master_ids_in_frame.add(master_id)
                                    if master_id in self.master_registry:
                                        self.master_registry[master_id]["last_frame_seen"] = frame_idx
                                        self.master_registry[master_id]["last_bbox"] = [x1, y1, x2, y2]
                                        self.master_registry[master_id]["total_hits"] += 1
                            else:
                                active_master_ids_in_frame.add(master_id)
                                if master_id in self.master_registry:
                                    self.master_registry[master_id]["last_frame_seen"] = frame_idx
                                    self.master_registry[master_id]["last_bbox"] = [x1, y1, x2, y2]
                                    self.master_registry[master_id]["total_hits"] += 1

                        # Step 2: Render visual bounding boxes & Master Track IDs
                        for raw_id, bbox in zip(raw_track_ids, xyxy_list):
                            x1, y1, x2, y2 = map(int, bbox)
                            x1, y1 = max(0, x1), max(0, y1)
                            x2, y2 = min(w, x2), min(h, y2)

                            m_id = self.raw_to_master_map.get(raw_id, raw_id)
                            m_info = self.master_registry.get(m_id, {})
                            m_status = m_info.get("status", "Pending")
                            m_name = m_info.get("person_name", "Pending")

                            if m_status == "Authorized":
                                color = (0, 255, 0)
                                label = f"ID #{m_id} | AUTH: {m_name}"
                            elif m_status == "Unauthorized":
                                color = (0, 0, 255)
                                label = f"ID #{m_id} | UNAUTHORIZED"
                            else:
                                color = (0, 255, 255)
                                label = f"ID #{m_id} | DETECTING..."

                            cv2.rectangle(frame, (x1, y1), (x2, y2), color, 2)
                            (w_text, h_text), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.55, 2)
                            text_y = max(y1 - 10, 20)
                            cv2.rectangle(frame, (x1, text_y - h_text - 4), (x1 + w_text + 6, text_y + 4), (0, 0, 0), -1)
                            cv2.putText(frame, label, (x1 + 3, text_y), cv2.FONT_HERSHEY_SIMPLEX, 0.55, color, 2)

                # Step 3: Screen Exit Finalization for lost master tracks
                for m_id, m_state in list(self.master_registry.items()):
                    if not m_state.get("exited_screen", False):
                        if frame_idx - m_state["last_frame_seen"] >= exit_threshold_frames:
                            m_state["exited_screen"] = True
                            
                            if m_state["status"] != "Authorized":
                                m_state["status"] = "Unauthorized"
                                m_state["person_name"] = "Unauthorized"
                                m_state["finalized"] = True
                                
                                log_key = f"unauth_exit_{m_id}"
                                if log_key not in self.logged_events and m_state.get("total_hits", 0) >= 3:
                                    self.logged_events.add(log_key)
                                    sys_time_str = datetime.now().strftime("%H:%M:%S")
                                    time_tag = format_time_str(start_dt, frame_idx, fps)
                                    elapsed_wall_sec = max(time.time() - start_proc_time, 0.001)
                                    current_proc_fps = frame_idx / elapsed_wall_sec
                                    speed_mult = current_proc_fps / max(fps, 1.0)
                                    print(f"[UNAUTHORIZED EXIT] Master Track #{m_id} left screen -> Finalized as Unauthorized! (Sys Time: {sys_time_str} | Video Time: {time_tag} | Frame {frame_idx} | Proc Speed: {current_proc_fps:.1f} FPS / {speed_mult:.1f}x)")

                in_person_scene = person_detected

                if show_live:
                    mode_tag = "2x SPEED (PERSON DETECTED)" if in_person_scene else f"FAST-FORWARD ({empty_frame_skip}x SPEED)"
                    tag_color = (0, 255, 0) if in_person_scene else (255, 165, 0)
                    cv2.putText(frame, f"MODE (NVDEC GPU): {mode_tag}", (15, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, tag_color, 2)

                    cv2.imshow("AI CCTV Analytics - NVDEC Hardware Accelerated", frame)
                    delay = 10 if in_person_scene else 1  # 10ms delay for 2x speed
                    if cv2.waitKey(delay) & 0xFF == ord('q'):
                        print("[INFO] Playback stopped by user.")
                        break

                frame_idx += 1

        finally:
            decoder.release()
            if show_live:
                cv2.destroyAllWindows()

        # Finalize non-authorized master tracks at video end
        for m_id, m_state in self.master_registry.items():
            if not m_state["finalized"] and m_state["status"] != "Authorized":
                m_state["status"] = "Unauthorized"
                m_state["person_name"] = "Unauthorized"
                m_state["finalized"] = True

        valid_master_tracks = []
        for m_id, state in self.master_registry.items():
            if state.get("total_hits", 0) >= 3 or state.get("status") == "Authorized":
                t_record = state.copy()
                t_record["first_seen_timestamp"] = format_time_str(start_dt, t_record.get("first_frame_detected", 0), fps)
                t_record["last_seen_timestamp"] = format_time_str(start_dt, t_record.get("last_frame_seen", 0), fps)
                t_record.pop("appearance_feature", None)
                valid_master_tracks.append(t_record)

        unique_authorized = set(t["person_name"] for t in valid_master_tracks if t["status"] == "Authorized")
        unique_unauthorized_masters = set(t["master_track_id"] for t in valid_master_tracks if t["status"] == "Unauthorized")

        elapsed_wall_sec = round(max(time.time() - start_proc_time, 0.001), 2)
        current_proc_fps = round(frame_idx / elapsed_wall_sec, 1)
        speed_mult = round(current_proc_fps / max(fps, 1.0), 1)

        summary_results = {
            "video_name": video_name,
            "video_start_timestamp": video_start_str or "N/A",
            "processing_time_seconds": elapsed_wall_sec,
            "processing_fps": current_proc_fps,
            "processing_speed_multiplier": f"{speed_mult}x Realtime",
            "total_frames_processed": frame_idx,
            "total_unique_tracks": len(valid_master_tracks),
            "authorized_unique_persons_count": len(unique_authorized),
            "authorized_persons_list": list(unique_authorized),
            "unauthorized_unique_persons_count": len(unique_unauthorized_masters),
            "tracks": valid_master_tracks
        }

        # Auto-save results to PostgreSQL database
        if save_video_processing_results is not None:
            save_video_processing_results(summary_results)

        return summary_results
