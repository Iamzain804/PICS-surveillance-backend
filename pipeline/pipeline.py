"""
Main single-pass video processing orchestration.

This is the real home of what used to be integrated_pipeline.py's
process_video_single_pass() and run_integrated_pipeline(). integrated_pipeline.py
now re-exports both for backward compatibility.

Two things changed in this move, deliberately, on top of module extraction:

  1. ``prev_frame = current_frame.copy()`` used to run unconditionally on
     every inference frame, but is only ever read again on the
     annotated-video (``not is_smart_decoder``) path -- in SmartVideoDecoder
     mode it was a ~6MB dead copy every motion frame for state nothing
     consumes. It's now only taken when it will actually be used. This is a
     performance cleanup, not a behavior change: the value it produced was
     already unused in smart-decoder mode.
  2. Optional early-exit support (``target_id`` / ``stop_on_match``): stop
     processing as soon as a specific employee has been recognized, for
     "find this person quickly" runs from the new CLI.

Everything else -- DB writes, event/attendance logic, checkpointing,
recognition thresholds, drift correction -- is moved verbatim.
"""

from __future__ import annotations

import os
import subprocess
import time
from collections import Counter
from datetime import datetime
from typing import Any, Optional, Union

import cv2
import numpy as np

from pipeline.checkpoint import load_checkpoint, save_checkpoint
from pipeline.config import PipelineConfig, load_pipeline_config
from pipeline.decoder import PrefetchedGPUVideoDecoder, SmartVideoDecoder
from pipeline.detector import get_yolo_model
from pipeline.logging_setup import get_logger
from pipeline.matcher import load_enrolled_employees, search_with_margin
from pipeline.motion import compute_motion_ratio
from pipeline.recognizer import check_face_quality_gate, compute_face_quality, get_insightface_app
from pipeline.timestamps import TimestampDriftCorrector, parse_video_start_time
from pipeline.tracker import TrackState
from pipeline.video_io import (
    create_video_writer,
    draw_hud,
    release_video_writer,
    resolve_video_input_path,
    resolve_video_output_path,
    write_video_frame,
)

logger = get_logger("pipeline")


def process_video_single_pass(
    video_record: Any,
    db: Any,
    app: Any = None,
    enrolled_employees: Optional[dict[str, Any]] = None,
    output_dir: Optional[str] = None,
    show_live: bool = False,
    video_start_time: Optional[str] = None,
    input_video_path: Optional[str] = None,
    config: Optional[PipelineConfig] = None,
    target_id: Optional[str] = None,
    stop_on_match: bool = False,
) -> dict[str, Any]:
    """
    Core single-pass video processing engine with motion gating, YOLO +
    ByteTrack person tracking, and InsightFace recognition with early
    lock-in.

    ``target_id`` + ``stop_on_match=True`` stop processing as soon as that
    employee id is recognized (status == "recognized"), instead of scanning
    the whole video -- useful for CLI "find this person" runs.
    """
    from ai.ocr_extractor import extract_video_metadata_from_frame, get_shared_ocr_reader
    from database.database import Event, ReviewQueue, Staff

    conf = config or load_pipeline_config()
    start_wall_time = time.time()

    # 1. Resolve inputs & models
    input_path = input_video_path or resolve_video_input_path(video_record, conf.backend_dir)
    if not os.path.exists(input_path):
        raise FileNotFoundError(f"Input video file does not exist: {input_path}")

    folder_type = getattr(video_record, "folder_type", "breakin") or "breakin"
    output_path = resolve_video_output_path(video_record, conf.backend_dir, output_dir)
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    if app is None:
        app = get_insightface_app()

    if enrolled_employees is None:
        enrolled_employees = load_enrolled_employees(conf.resolved_encodings_pkl_path(), backend_dir=conf.backend_dir)

    staff_db_name_map: dict[str, str] = {}
    try:
        for st in db.query(Staff).all():
            if st.staff_id:
                staff_db_name_map[str(st.staff_id).strip()] = st.name
    except Exception:
        pass

    yolo_model = get_yolo_model(config=conf)

    # 2. Initialize video decoder & metadata.
    # SmartVideoDecoder (skips full decode on static frames) is only safe
    # when annotated-video output is off -- draw_hud/write_video_frame need
    # every frame's real pixels when SAVE_ANNOTATED_VIDEO is True, motion or
    # not, so that mode keeps the full-decode PrefetchedGPUVideoDecoder and
    # the original inline cv2 motion-gating algorithm.
    is_smart_decoder = not conf.save_annotated_video
    decoder: Union[SmartVideoDecoder, PrefetchedGPUVideoDecoder]
    if is_smart_decoder:
        decoder = SmartVideoDecoder(
            input_path,
            queue_size=conf.queue_size,
            downscale_size=conf.motion_downscale_size,
            motion_threshold_ratio=conf.motion_threshold_ratio,
            motion_pixel_diff_thresh=conf.motion_pixel_diff_thresh,
        )
    else:
        decoder = PrefetchedGPUVideoDecoder(input_path, queue_size=conf.queue_size)

    width = decoder.width
    height = decoder.height
    fps = max(float(decoder.fps), 1.0)
    total_frames = int(decoder.total_frames)

    start_time_to_parse = video_start_time or getattr(video_record, "video_start_time", None)
    video_start_dt = parse_video_start_time(start_time_to_parse)
    camera_name = getattr(video_record, "camera_name", None)

    read_res = decoder.read()
    ret = read_res[0]
    first_frame = read_res[1]
    if not ret or first_frame is None:
        decoder.release()
        raise ValueError(f"Unable to read frames from video: {input_path}")

    if video_start_dt is None:
        ocr_dt, ocr_dt_str, ocr_cam = extract_video_metadata_from_frame(first_frame)
        if ocr_dt:
            video_start_dt = ocr_dt
            if hasattr(video_record, "video_start_time"):
                video_record.video_start_time = ocr_dt_str
        if ocr_cam and not camera_name:
            camera_name = ocr_cam
            if hasattr(video_record, "camera_name"):
                video_record.camera_name = ocr_cam

    stem, _ = os.path.splitext(os.path.basename(input_path))
    checkpoint_path = os.path.join(os.path.dirname(output_path), f"{stem}_checkpoint.json")
    checkpoint_data = load_checkpoint(checkpoint_path)

    track_state = TrackState()
    logged_events: dict[int, Any] = {}
    emp_last_event_sec: dict[str, float] = {}
    emp_event_state: dict[str, str] = {}
    parts_list: list[str] = []

    frame_idx = 0

    if checkpoint_data:
        frame_idx = checkpoint_data.get("last_frame_idx", 0)
        logger.info("Seeking decoder to frame %d...", frame_idx)
        decoder.seek(frame_idx)

        for tid_str, bbox in checkpoint_data.get("active_tracks", {}).items():
            tid = int(tid_str)
            track_state.active_bboxes[tid] = bbox
            track_state.last_seen[tid] = frame_idx

        for tid_str, info in checkpoint_data.get("track_recognition_cache", {}).items():
            tid = int(tid_str)
            track_state.cache[tid] = {
                "status": info.get("status"),
                "emp_id": info.get("emp_id"),
                "emp_name": info.get("emp_name"),
                "conf": info.get("conf"),
                "attempts": info.get("attempts"),
                "face_samples": [],
                "locked": info.get("locked"),
                "first_frame": info.get("first_frame"),
                "first_timestamp": info.get("first_timestamp"),
            }

        for tid_str, evt_id in checkpoint_data.get("logged_event_ids", {}).items():
            tid = int(tid_str)
            evt_obj = db.query(Event).filter(Event.id == evt_id).first()
            if evt_obj:
                logged_events[tid] = evt_obj

        parts_list = checkpoint_data.get("parts_list", [])
        current_output_path = f"{output_path}_part_{frame_idx}.mp4"
        parts_list.append(current_output_path)
    else:
        current_output_path = output_path
        parts_list = [current_output_path]

    out_writer, enc_mode = create_video_writer(
        current_output_path, int(width), int(height), fps, save_annotated_video=conf.save_annotated_video
    )
    logger.info("Video hardware encoder mode: [%s]", enc_mode)

    prev_frame: Optional[np.ndarray] = None
    motion_gated_count = 0
    inference_count = 0
    current_frame: Optional[np.ndarray] = first_frame
    early_exit = False

    ocr_reader = get_shared_ocr_reader()
    if first_frame is not None and ocr_reader is not None and video_start_dt is None:
        try:
            f1_dt, f1_str, _ = extract_video_metadata_from_frame(first_frame, ocr_reader, filename=os.path.basename(input_path))
            if f1_dt:
                video_start_dt = f1_dt
                logger.info("Frame 1 video start watermark extracted: %s", f1_str)
        except Exception as f1_ocr_err:
            logger.warning("Frame 1 OCR warning: %s", f1_ocr_err)

    drift_corrector = TimestampDriftCorrector(fps, video_start_dt)

    logger.info("Processing: %s (%s)", os.path.basename(input_path), folder_type.upper())
    logger.info("Input: %s | Size: %dx%d @ %.1f FPS", input_path, width, height, fps)
    logger.info("Output target: %s", output_path)
    logger.info("Decoder engine: %s", "SmartVideoDecoder (fast gating)" if is_smart_decoder else "PrefetchedGPUVideoDecoder")
    if target_id and stop_on_match:
        logger.info("Early-exit armed: will stop once employee %s is recognized.", target_id)
    start_session_frame = frame_idx
    start_wall_time = time.time()

    try:
        while True:
            if current_frame is None:
                read_res = decoder.read()
                ret = read_res[0]
                if not ret:
                    break
                current_frame = read_res[1]

            frame_idx += 1

            if total_frames > 0 and frame_idx % 250 == 0:
                elapsed_so_far = max(0.01, time.time() - start_wall_time)
                session_frames = max(1, frame_idx - start_session_frame)
                curr_proc_fps = session_frames / elapsed_so_far
                remaining_frames = max(0, total_frames - frame_idx)
                eta_sec = remaining_frames / max(0.1, curr_proc_fps)
                pct = (frame_idx / total_frames) * 100.0
                h, m, s = int(eta_sec // 3600), int((eta_sec % 3600) // 60), int(eta_sec % 60)
                speed_mult = round(curr_proc_fps / fps, 1)
                logger.info(
                    "Progress: %s | Frame %d/%d (%.1f%%) | %.1f FPS (%sx) | ETA %02d:%02d:%02d",
                    os.path.basename(input_path), frame_idx, total_frames, pct, curr_proc_fps, speed_mult, h, m, s,
                )

            real_timestamp = drift_corrector.get_online_timestamp(frame_idx - 1)

            # SmartVideoDecoder: static frame skipped at decoder level (no full BGR allocation)
            if is_smart_decoder and current_frame is None:
                motion_gated_count += 1
                track_state.cleanup_gated(frame_idx, conf.track_lost_max_frames)
                continue

            # From here on for this iteration, current_frame is a real decoded
            # frame: either is_smart_decoder is False (PrefetchedGPUVideoDecoder
            # never returns None), or it is True and the None case above already
            # continued. mypy's flow analysis doesn't carry that across the
            # while-loop back-edge, so this makes it explicit.
            assert current_frame is not None
            is_sample_frame = (frame_idx % conf.frame_sample_interval == 0) or (frame_idx == 1)
            if not is_sample_frame:
                draw_hud(
                    frame=current_frame, video_record=video_record, folder_type=folder_type,
                    real_timestamp=real_timestamp, width=width,
                    active_tracks=track_state.active_bboxes, track_recognition_cache=track_state.cache,
                )
                write_video_frame(out_writer, enc_mode, current_frame)
                if show_live:
                    cv2.imshow("EPIC Video AI Pipeline", current_frame)
                    if cv2.waitKey(1) & 0xFF == ord("q"):
                        break
                current_frame = None
                continue

            # Inline motion gating for the fallback/annotated-video-saving path only
            if not is_smart_decoder and prev_frame is not None:
                motion_ratio = compute_motion_ratio(prev_frame, current_frame, conf.motion_downscale_size, conf.motion_pixel_diff_thresh)

                if motion_ratio < conf.motion_threshold_ratio:
                    motion_gated_count += 1
                    track_state.cleanup_gated(frame_idx, conf.track_lost_max_frames)
                    draw_hud(
                        frame=current_frame, video_record=video_record, folder_type=folder_type,
                        real_timestamp=real_timestamp, width=width,
                        active_tracks=track_state.active_bboxes, track_recognition_cache=track_state.cache,
                    )
                    write_video_frame(out_writer, enc_mode, current_frame)
                    if show_live:
                        cv2.imshow("EPIC Video AI Pipeline", current_frame)
                        if cv2.waitKey(1) & 0xFF == ord("q"):
                            break
                    current_frame = None
                    continue

            if not is_smart_decoder:
                # Only the annotated-video path re-reads prev_frame (see module docstring).
                prev_frame = current_frame.copy()
            inference_count += 1

            detections = yolo_model.track(
                source=current_frame, persist=True,
                classes=[conf.person_class_id], conf=conf.confidence_threshold, verbose=False,
            )

            # Prune stale tracks and logged_events before processing detections
            track_state.cleanup_post_detection(frame_idx, conf.track_lost_max_frames, logged_events)

            if detections and len(detections) > 0 and detections[0].boxes is not None:
                boxes = detections[0].boxes
                if boxes.id is not None:
                    track_ids = boxes.id.cpu().numpy().astype(int)
                    xyxy_boxes = boxes.xyxy.cpu().numpy()

                    for box, track_id in zip(xyxy_boxes, track_ids):
                        x1, y1, x2, y2 = map(int, box)
                        is_new_track = (int(track_id) not in track_state.cache)
                        track_state.register_detection(int(track_id), (x1, y1, x2, y2), frame_idx)

                        crop_x1, crop_y1 = max(0, x1), max(0, y1)
                        crop_x2, crop_y2 = min(width, x2), min(height, y2)

                        cache = track_state.get_or_create_cache_entry(int(track_id), frame_idx, real_timestamp)

                        if is_new_track:
                            video_id_val = getattr(video_record, "id", None)
                            if video_id_val is not None:
                                existing_evt = db.query(Event).filter(
                                    Event.video_id == video_id_val, Event.track_id == int(track_id), Event.frame_number == frame_idx,
                                ).first()

                                if existing_evt:
                                    logged_events[track_id] = existing_evt
                                else:
                                    init_evt_type = "Break In" if "breakin" in str(folder_type).lower() else ("Break Out" if "breakout" in str(folder_type).lower() else ("check_in" if "checkin" in str(folder_type).lower() else "Person Entered"))
                                    evt = Event(
                                        video_id=video_id_val, camera_role=folder_type, track_id=int(track_id),
                                        event_type=init_evt_type, timestamp=real_timestamp, frame_number=frame_idx,
                                        confidence=0.85, status="pending", recognition_status="pending",
                                        employee_name=f"Person #{track_id}",
                                    )
                                    db.add(evt)
                                    try:
                                        db.flush()
                                        logged_events[track_id] = evt
                                    except Exception as db_err:
                                        # Most likely the (video_id, track_id, frame_number) unique
                                        # constraint -- e.g. a racing chunk-worker already logged
                                        # this exact event. Roll back so the session isn't left
                                        # poisoned for the rest of this video, and recover the
                                        # existing row so later recognition updates still land.
                                        db.rollback()
                                        logger.warning("Event insert conflicted (likely duplicate), recovering existing row: %s", db_err)
                                        existing_evt = db.query(Event).filter(
                                            Event.video_id == video_id_val, Event.track_id == int(track_id), Event.frame_number == frame_idx,
                                        ).first()
                                        if existing_evt:
                                            logged_events[track_id] = existing_evt

                                try:
                                    person_crop_init = current_frame[crop_y1:crop_y2, crop_x1:crop_x2]
                                    if person_crop_init.size > 0:
                                        event_crops_dir = os.path.abspath(os.path.join(conf.backend_dir, "data", "event_crops"))
                                        os.makedirs(event_crops_dir, exist_ok=True)
                                        evt_obj_for_crop = logged_events.get(track_id)
                                        if evt_obj_for_crop and hasattr(evt_obj_for_crop, "id") and evt_obj_for_crop.id:
                                            crop_save_path = os.path.join(event_crops_dir, f"{evt_obj_for_crop.id}_initial.jpg")
                                            cv2.imwrite(crop_save_path, person_crop_init)
                                except Exception:
                                    pass

                        if not cache["locked"]:
                            person_crop = current_frame[crop_y1:crop_y2, crop_x1:crop_x2]
                            if person_crop.size > 0 and person_crop.shape[0] >= 30 and person_crop.shape[1] >= 30:
                                try:
                                    faces = app.get(person_crop)
                                    cache["attempts"] += 1
                                    if faces:
                                        for face in faces:
                                            if check_face_quality_gate(face):
                                                q = compute_face_quality(face)
                                                cache["face_samples"].append((q, face))
                                except Exception:
                                    pass

                            if cache["face_samples"] or cache["attempts"] >= conf.max_face_attempts_lock:
                                if cache["face_samples"]:
                                    all_samples = cache["face_samples"]

                                    votes: list[str] = []
                                    candidate_sims: dict[str, list[float]] = {}
                                    for q, face in all_samples:
                                        top1_id, top1_sim, second_id, second_sim = search_with_margin(face, enrolled_employees)
                                        if top1_id is not None:
                                            margin = top1_sim - second_sim
                                            if top1_sim >= conf.recognition_lock_threshold:
                                                votes.append(top1_id)
                                                candidate_sims.setdefault(top1_id, []).append(top1_sim)
                                            elif top1_sim >= conf.ambiguous_threshold and margin < conf.ambiguous_margin:
                                                votes.append("ambiguous")
                                            else:
                                                votes.append("unrecognized")
                                        else:
                                            votes.append("unrecognized")

                                    tally = Counter(votes)

                                    best_candidate = None
                                    best_sim = 0.0
                                    for candidate, sims in candidate_sims.items():
                                        c_max = max(sims)
                                        if c_max > best_sim:
                                            best_sim = c_max
                                            best_candidate = candidate

                                    final_status = "unrecognized"
                                    final_emp_id = None
                                    final_emp_name = None
                                    final_conf = 0.0

                                    if best_candidate and best_sim >= conf.recognition_lock_threshold:
                                        final_status = "recognized"
                                        final_emp_id = best_candidate
                                        final_emp_name = staff_db_name_map.get(str(best_candidate), str(best_candidate))
                                        final_conf = best_sim
                                    elif tally["ambiguous"] > 0:
                                        final_status = "ambiguous"
                                        amb_names = []
                                        for q, face in all_samples:
                                            t1_id, t1_sim, t2_id, t2_sim = search_with_margin(face, enrolled_employees)
                                            if t1_id and t1_sim >= conf.ambiguous_display_threshold:
                                                t1_info = enrolled_employees.get(t1_id, {})
                                                name1 = t1_info.get("name", str(t1_id)) if isinstance(t1_info, dict) else str(t1_id)
                                                amb_names.append(f"{name1} ({int(t1_sim*100)}%)")
                                        amb_names = list(dict.fromkeys(amb_names))
                                        final_emp_name = ", ".join(amb_names) if amb_names else "Ambiguous"
                                    else:
                                        final_status = "unrecognized"
                                        final_emp_name = f"Person #{track_id}"

                                    cache["status"] = final_status
                                    cache["emp_id"] = final_emp_id
                                    cache["emp_name"] = final_emp_name
                                    cache["conf"] = final_conf
                                    cache["locked"] = final_status == "recognized"

                                    evt_obj = logged_events.get(track_id)
                                    if evt_obj:
                                        evt_obj.recognition_status = final_status
                                        evt_obj.status = "normal" if final_status == "recognized" else "unrecognized"
                                        evt_obj.employee_id = final_emp_id
                                        evt_obj.employee_name = final_emp_name
                                        evt_obj.recognition_confidence = final_conf
                                        evt_obj.recognized_at = datetime.utcnow()

                                        evt_obj.timestamp = str(real_timestamp)

                                        if final_emp_id:
                                            try:
                                                stf_num = int(str(final_emp_id).replace("STF-", "").lstrip("0") or "0")
                                                stf = db.query(Staff).filter(
                                                    (Staff.staff_code == str(final_emp_id)) | (Staff.staff_id == str(final_emp_id)) | (Staff.id == stf_num)
                                                ).first()
                                                if stf:
                                                    evt_obj.staff_id = stf.id
                                                    evt_obj.employee_name = stf.name
                                            except Exception:
                                                pass

                                        folder_type_clean = (getattr(video_record, "folder_type", "") or "").lower()
                                        if "breakin" in folder_type_clean:
                                            evt_obj.event_type = "Break In"
                                            evt_obj.camera_role = "breakin"
                                        elif "breakout" in folder_type_clean:
                                            evt_obj.event_type = "Break Out"
                                            evt_obj.camera_role = "breakout"
                                        elif ("att" in folder_type_clean or "gate" in folder_type_clean) and final_status == "recognized" and final_emp_id:
                                            curr_sec = float(frame_idx) / (float(fps) if fps else 30.0)
                                            last_sec = emp_last_event_sec.get(str(final_emp_id), -999.0)
                                            if (curr_sec - last_sec) >= conf.attendance_cooldown_seconds:
                                                last_st = emp_event_state.get(str(final_emp_id), "checkout")
                                                new_st = "checkin" if last_st == "checkout" else "checkout"
                                                emp_last_event_sec[str(final_emp_id)] = curr_sec
                                                emp_event_state[str(final_emp_id)] = new_st
                                                evt_obj.event_type = "check_in" if new_st == "checkin" else "check_out"
                                                evt_obj.camera_role = "attendance"
                                                try:
                                                    db.commit()
                                                except Exception:
                                                    pass

                                        if final_status == "ambiguous":
                                            person_crop = current_frame[crop_y1:crop_y2, crop_x1:crop_x2]
                                            if person_crop.size > 0:
                                                crops_dir = os.path.abspath(os.path.join(conf.backend_dir, "data", "review_crops"))
                                                os.makedirs(crops_dir, exist_ok=True)
                                                crop_path = os.path.join(crops_dir, f"{evt_obj.id}.jpg")
                                                cv2.imwrite(crop_path, person_crop)
                                                db.add(ReviewQueue(
                                                    event_id=evt_obj.id, suggested_staff_id=final_emp_id,
                                                    confidence=final_conf, status="pending", face_crop_path=crop_path,
                                                ))

                                        try:
                                            person_crop_final = current_frame[crop_y1:crop_y2, crop_x1:crop_x2]
                                            if person_crop_final.size > 0 and evt_obj:
                                                event_crops_dir = os.path.abspath(os.path.join(conf.backend_dir, "data", "event_crops"))
                                                os.makedirs(event_crops_dir, exist_ok=True)
                                                crop_lockin_path = os.path.join(event_crops_dir, f"{evt_obj.id}_lockin.jpg")
                                                cv2.imwrite(crop_lockin_path, person_crop_final)
                                                if hasattr(evt_obj, "face_crop_path"):
                                                    evt_obj.face_crop_path = crop_lockin_path
                                        except Exception:
                                            pass

                                        try:
                                            db.commit()
                                        except Exception:
                                            db.rollback()
                                            logged_events.pop(track_id, None)

                                    if target_id is not None and stop_on_match and final_status == "recognized" and str(final_emp_id) == str(target_id):
                                        logger.info("Target employee %s recognized at frame %d -- stopping early (stop_on_match).", target_id, frame_idx)
                                        early_exit = True

                                elif cache["attempts"] >= conf.max_face_attempts_lock and not cache["locked"]:
                                    cache["status"] = "unrecognized"
                                    cache["emp_name"] = f"Person #{track_id}"
                                    cache["locked"] = True

                                    evt_obj = logged_events.get(track_id)
                                    if evt_obj:
                                        evt_obj.recognition_status = "unrecognized"
                                        evt_obj.employee_name = cache["emp_name"]
                                        evt_obj.recognition_confidence = 0.0
                                        try:
                                            db.commit()
                                        except Exception:
                                            db.rollback()
                                            logged_events.pop(track_id, None)

            track_state.cleanup_post_detection(frame_idx, conf.post_detection_stale_frames, logged_events)

            if conf.save_annotated_video:
                draw_hud(
                    frame=current_frame, video_record=video_record, folder_type=folder_type,
                    real_timestamp=real_timestamp, width=width,
                    active_tracks=track_state.active_bboxes, track_recognition_cache=track_state.cache,
                )
                write_video_frame(out_writer, enc_mode, current_frame)

            if frame_idx % 9000 == 0:
                save_checkpoint(checkpoint_path, frame_idx, track_state.active_bboxes, track_state.cache, logged_events, parts_list)

            if show_live:
                cv2.imshow("EPIC Video AI Pipeline", current_frame)
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break

            current_frame = None

            if early_exit:
                break

    finally:
        decoder.release()
        release_video_writer(out_writer, enc_mode)
        if show_live:
            cv2.destroyAllWindows()

        if len(parts_list) > 1:
            logger.info("Checkpoint recombined video parts detected: %s", parts_list)
            list_file_path = f"{output_path}_parts.txt"
            try:
                with open(list_file_path, "w", encoding="utf-8") as lf:
                    for part in parts_list:
                        lf.write(f"file '{part.replace(chr(92), '/')}'\n")

                concat_cmd = ["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", list_file_path, "-c", "copy", output_path]
                logger.info("Merging segments via FFmpeg copy: %s", " ".join(concat_cmd))
                subprocess.run(concat_cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

                for part in parts_list:
                    if os.path.exists(part):
                        os.remove(part)
                if os.path.exists(list_file_path):
                    os.remove(list_file_path)
                logger.info("Segment merge complete and temporary parts cleaned.")
            except Exception as concat_err:
                logger.error("Segment concatenation failed: %s", concat_err)

        if os.path.exists(checkpoint_path):
            try:
                os.remove(checkpoint_path)
                logger.info("Removed checkpoint file upon successful completion: %s", checkpoint_path)
            except Exception as cp_err:
                logger.warning("Failed to delete checkpoint file: %s", cp_err)

        try:
            video_id_val = getattr(video_record, "id", None)
            drift_corrector.fit_and_correct_events(video_id_val, db)
        except Exception as drift_err:
            logger.warning("Drift correction failed: %s", drift_err)

    try:
        if hasattr(video_record, "status") and not early_exit:
            video_record.status = "completed"
        db.commit()
    except Exception as e:
        logger.warning("Failed to commit video status: %s", e)
        db.rollback()

    elapsed_wall = max(0.01, time.time() - start_wall_time)
    proc_fps = frame_idx / elapsed_wall
    recognized_count = sum(1 for t in track_state.cache.values() if t["status"] == "recognized")

    summary = {
        "video_id": getattr(video_record, "id", None),
        "filename": getattr(video_record, "filename", os.path.basename(input_path)),
        "folder_type": folder_type,
        "input_path": input_path,
        "output_path": output_path,
        "total_frames": frame_idx,
        "duration_seconds": round(frame_idx / fps, 2),
        "processing_time_seconds": round(elapsed_wall, 2),
        "processing_fps": round(proc_fps, 1),
        "speed_multiplier": f"{round(proc_fps / fps, 1)}x Realtime",
        "total_tracks": len(track_state.cache),
        "recognized_persons": recognized_count,
        "events_logged": len(logged_events),
        "motion_gated_frames_skipped": motion_gated_count,
        "inference_frames_processed": inference_count,
        "early_exit": early_exit,
    }

    logger.info("Finished %s", os.path.basename(input_path))
    logger.info("Processed: %d frames in %.2fs (%.1f FPS / %s)", frame_idx, elapsed_wall, proc_fps, summary["speed_multiplier"])
    logger.info("Motion gating: %d static frames skipped | %d inference frames executed", motion_gated_count, inference_count)
    logger.info("Tracks: %d total | %d recognized | %d events logged", len(track_state.cache), recognized_count, len(logged_events))
    return summary


def _parse_real_timestamp(real_timestamp: str) -> Optional[datetime]:
    """Parses the '%d-%m-%Y %H:%M:%S' timestamp format used for real_timestamp values."""
    try:
        return datetime.strptime(real_timestamp, "%d-%m-%Y %H:%M:%S")
    except (ValueError, TypeError):
        return None


def run_integrated_pipeline(db: Any = None, config: Optional[PipelineConfig] = None) -> None:
    """Orchestrates running single-pass processing on all pending videos."""
    from database.database import SessionLocal, Video

    close_db = False
    if db is None:
        db = SessionLocal()
        close_db = True
    try:
        pending = db.query(Video).filter(Video.status == "pending").all()
        if not pending:
            logger.info("No pending videos to annotate/process.")
            return

        def get_video_priority(v: Any) -> int:
            ft = (v.folder_type or "").lower()
            return 0 if "att" in ft else 1

        pending.sort(key=get_video_priority)

        for video in pending:
            try:
                process_video_single_pass(video, db, config=config)
            except Exception as e:
                logger.error("Failed for video %s: %s", video.filename, e)
    finally:
        if close_db:
            db.close()
