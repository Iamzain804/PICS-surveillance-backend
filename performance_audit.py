"""
EPIC Performance Audit - Phase 1-14 Profiling Harness
======================================================
Non-destructive profiler that wraps the existing integrated_pipeline
to measure every stage without modifying production code.

Usage:
    python performance_audit.py [video_path]

If video_path is omitted, uses the first pending video from DB.
"""

import os, sys, time, json, pickle, threading
import numpy as np
import cv2
import subprocess

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

# GPU monitoring thread (nvidia-smi at 1s interval)
_gpu_samples = []
_gpu_monitor_stop = threading.Event()


def _gpu_monitor_thread():
    while not _gpu_monitor_stop.is_set():
        try:
            out = subprocess.check_output(
                ["nvidia-smi",
                 "--query-gpu=timestamp,utilization.gpu,utilization.memory,"
                 "memory.used,memory.total,power.draw,temperature.gpu,"
                 "clocks.current.sm,clocks.current.memory,pstate",
                 "--format=csv,noheader,nounits"],
                timeout=3, text=True
            ).strip()
            _gpu_samples.append(out)
        except Exception:
            pass
        _gpu_monitor_stop.wait(1.0)


def start_gpu_monitor():
    t = threading.Thread(target=_gpu_monitor_thread, daemon=True)
    t.start()
    return t


def stop_gpu_monitor():
    _gpu_monitor_stop.set()


class StageTimer:
    def __init__(self):
        self.stages = {}
        self._active = {}
        self.counts = {}

    def start(self, name):
        self._active[name] = time.perf_counter()

    def stop(self, name):
        if name in self._active:
            dt = time.perf_counter() - self._active.pop(name)
            self.stages[name] = self.stages.get(name, 0.0) + dt
            self.counts[name] = self.counts.get(name, 0) + 1
            return dt
        return 0.0

    def report(self):
        total = sum(self.stages.values()) or 1.0
        items = sorted(self.stages.items(), key=lambda x: -x[1])
        lines = []
        for name, t in items:
            cnt = self.counts.get(name, 1)
            pct = (t / total) * 100
            avg_ms = (t / cnt) * 1000 if cnt else 0
            lines.append("  {:40s}  {:9.3f}s  ({:5.1f}%)  count={:7d}  avg={:.3f}ms".format(name, t, pct, cnt, avg_ms))
        return "\n".join(lines), total


def run_audit(video_path=None):
    from database.database import SessionLocal, Video, Event, Staff
    from ai.gpu_decoder import NVDECGPUVideoDecoder, PrefetchedGPUVideoDecoder
    from ai.ocr_extractor import extract_video_metadata_from_frame, get_shared_ocr_reader
    from integrated_pipeline import (
        get_yolo_model, get_insightface_app, load_enrolled_employees,
        search_with_margin, check_face_quality_gate, compute_face_quality,
        parse_video_start_time, FRAME_SAMPLE_INTERVAL,
        MOTION_DOWNSCALE_SIZE, MOTION_THRESHOLD_RATIO, MOTION_PIXEL_DIFF_THRESH,
        PERSON_CLASS_ID, CONFIDENCE_THRESHOLD, MAX_FACE_ATTEMPTS_LOCK,
        RECOGNITION_THRESHOLD, SAVE_ANNOTATED_VIDEO, TimestampDriftCorrector
    )

    db = SessionLocal()
    timer = StageTimer()

    # Resolve video
    if video_path and os.path.exists(video_path):
        class _Stub:
            id = None
            filename = os.path.basename(video_path)
            folder_type = "attendance"
            file_path = video_path
            camera_name = "audit"
            video_start_time = None
            status = "pending"
        video_record = _Stub()
    else:
        video_record = db.query(Video).filter(Video.status.in_(["pending", "completed"])).first()
        if not video_record:
            print("[AUDIT] No video found in DB. Pass a video path as argument.")
            return
        video_path = video_record.file_path

    if not os.path.exists(video_path):
        print("[AUDIT] Video file not found: {}".format(video_path))
        return

    print("=" * 80)
    print("  EPIC Performance Audit - Profiling Existing Pipeline")
    print("=" * 80)

    timer.start("model_load_yolo")
    yolo_model = get_yolo_model()
    timer.stop("model_load_yolo")

    timer.start("model_load_insightface")
    face_app = get_insightface_app()
    timer.stop("model_load_insightface")

    timer.start("load_enrolled_employees")
    enrolled = load_enrolled_employees()
    timer.stop("load_enrolled_employees")
    num_enrolled = len(enrolled)

    staff_db_name_map = {}
    try:
        for st in db.query(Staff).all():
            if st.staff_id:
                staff_db_name_map[str(st.staff_id).strip()] = st.name
    except Exception:
        pass

    timer.start("ocr_reader_init")
    ocr_reader = get_shared_ocr_reader()
    timer.stop("ocr_reader_init")

    timer.start("video_open")
    decoder = PrefetchedGPUVideoDecoder(video_path, queue_size=6)
    timer.stop("video_open")

    width, height = decoder.width, decoder.height
    fps = max(float(decoder.fps), 1.0)
    total_frames = int(decoder.total_frames)
    video_duration_sec = total_frames / fps

    print("\n[VIDEO] {}".format(os.path.basename(video_path)))
    print("  Resolution: {}x{}  FPS: {:.1f}  Total Frames: {}".format(width, height, fps, total_frames))
    print("  Video Duration: {:.1f}s  ({:.1f} min)".format(video_duration_sec, video_duration_sec / 60))
    print("  Decoder HW Accelerated: {}".format(decoder.is_hardware_accelerated))
    print("  Enrolled Employees: {}".format(num_enrolled))
    print("  Frame Sample Interval: {}".format(FRAME_SAMPLE_INTERVAL))
    print("  Motion Downscale: {}".format(MOTION_DOWNSCALE_SIZE))
    print("  Motion Threshold: {}".format(MOTION_THRESHOLD_RATIO))
    print("  YOLO Confidence: {}".format(CONFIDENCE_THRESHOLD))
    print("  Annotated Video Output: {}".format(SAVE_ANNOTATED_VIDEO))

    start_gpu_monitor()

    timer.start("first_frame_read")
    ret, first_frame = decoder.read()
    timer.stop("first_frame_read")

    if not ret or first_frame is None:
        print("[AUDIT] Cannot read first frame.")
        decoder.release()
        return

    timer.start("ocr_first_frame")
    video_start_dt = None
    try:
        ocr_dt, ocr_str, ocr_cam = extract_video_metadata_from_frame(first_frame, ocr_reader)
        if ocr_dt:
            video_start_dt = ocr_dt
    except Exception:
        pass
    timer.stop("ocr_first_frame")

    drift_corrector = TimestampDriftCorrector(fps, video_start_dt)

    prev_frame = None
    current_frame = first_frame
    frame_idx = 0
    motion_gated = 0
    inference_frames = 0
    track_cache = {}
    active_track_bboxes = {}
    active_track_last_seen = {}

    decode_times = []
    yolo_times = []
    face_det_times = []
    face_search_times = []
    motion_gate_times = []

    max_frames = min(total_frames, 5000)
    print("\n[PROFILING] Processing first {} frames...".format(max_frames))

    wall_start = time.perf_counter()

    try:
        while frame_idx < max_frames:
            if current_frame is None:
                timer.start("video_decode")
                ret, current_frame = decoder.read()
                dt = timer.stop("video_decode")
                decode_times.append(dt)
                if not ret or current_frame is None:
                    break

            frame_idx += 1

            is_sample_frame = (frame_idx % FRAME_SAMPLE_INTERVAL == 0) or (frame_idx == 1)
            if not is_sample_frame:
                current_frame = None
                continue

            if prev_frame is not None:
                timer.start("motion_gating")
                small_prev = cv2.resize(prev_frame, MOTION_DOWNSCALE_SIZE)
                small_curr = cv2.resize(current_frame, MOTION_DOWNSCALE_SIZE)
                diff = cv2.absdiff(small_prev, small_curr)
                gray_diff = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
                _, thresh_diff = cv2.threshold(gray_diff, MOTION_PIXEL_DIFF_THRESH, 255, cv2.THRESH_BINARY)
                non_zero = cv2.countNonZero(thresh_diff)
                total_pixels = float(MOTION_DOWNSCALE_SIZE[0] * MOTION_DOWNSCALE_SIZE[1])
                motion_ratio = non_zero / total_pixels
                dt_mg = timer.stop("motion_gating")
                motion_gate_times.append(dt_mg)

                if motion_ratio < MOTION_THRESHOLD_RATIO:
                    motion_gated += 1
                    current_frame = None
                    continue

            prev_frame = current_frame.copy()
            inference_frames += 1

            timer.start("yolo_inference")
            results = yolo_model.track(
                source=current_frame,
                persist=True,
                classes=[PERSON_CLASS_ID],
                conf=CONFIDENCE_THRESHOLD,
                verbose=False
            )
            dt_yolo = timer.stop("yolo_inference")
            yolo_times.append(dt_yolo)

            timer.start("yolo_postprocess")
            current_frame_track_ids = set()
            num_persons = 0
            if results and len(results) > 0 and results[0].boxes is not None:
                boxes = results[0].boxes
                if boxes.id is not None:
                    track_ids = boxes.id.cpu().numpy().astype(int)
                    xyxy_boxes = boxes.xyxy.cpu().numpy()
                    num_persons = len(track_ids)

                    for box, track_id in zip(xyxy_boxes, track_ids):
                        current_frame_track_ids.add(track_id)
                        active_track_last_seen[track_id] = frame_idx
                        x1, y1, x2, y2 = map(int, box)
                        active_track_bboxes[track_id] = [x1, y1, x2, y2]

                        crop_x1, crop_y1 = max(0, x1), max(0, y1)
                        crop_x2, crop_y2 = min(width, x2), min(height, y2)

                        if track_id not in track_cache:
                            track_cache[track_id] = {
                                "status": "pending", "emp_id": None,
                                "emp_name": "Person #{}".format(track_id), "conf": 0.0,
                                "attempts": 0, "face_samples": [], "locked": False,
                                "first_frame": frame_idx
                            }

                        cache = track_cache[track_id]

                        if not cache["locked"]:
                            person_crop = current_frame[crop_y1:crop_y2, crop_x1:crop_x2]
                            if person_crop.size > 0 and person_crop.shape[0] >= 30 and person_crop.shape[1] >= 30:
                                timer.start("face_detection")
                                try:
                                    faces = face_app.get(person_crop)
                                    cache["attempts"] += 1
                                    if faces:
                                        for face in faces:
                                            if check_face_quality_gate(face):
                                                q = compute_face_quality(face)
                                                cache["face_samples"].append((q, face))
                                except Exception:
                                    pass
                                dt_fd = timer.stop("face_detection")
                                face_det_times.append(dt_fd)

                            if cache["face_samples"]:
                                timer.start("face_search")
                                all_samples = cache["face_samples"]
                                best_sim = 0.0
                                best_candidate = None
                                for q_val, face_obj in all_samples:
                                    t1_id, t1_sim, t2_id, t2_sim = search_with_margin(face_obj, enrolled)
                                    if t1_id and t1_sim > best_sim:
                                        best_sim = t1_sim
                                        best_candidate = t1_id

                                if best_candidate and best_sim >= 0.44:
                                    cache["status"] = "recognized"
                                    cache["emp_id"] = best_candidate
                                    cache["locked"] = True
                                elif cache["attempts"] >= MAX_FACE_ATTEMPTS_LOCK:
                                    cache["locked"] = True

                                dt_fs = timer.stop("face_search")
                                face_search_times.append(dt_fs)

            timer.stop("yolo_postprocess")

            timer.start("track_cleanup")
            lost = [tid for tid, lf in active_track_last_seen.items() if (frame_idx - lf) > 30]
            for tid in lost:
                active_track_bboxes.pop(tid, None)
                active_track_last_seen.pop(tid, None)
                track_cache.pop(tid, None)
            timer.stop("track_cleanup")

            if frame_idx % 500 == 0:
                elapsed = time.perf_counter() - wall_start
                curr_fps = frame_idx / elapsed
                pct = (frame_idx / max_frames) * 100
                print("  [AUDIT] Frame {}/{} ({:.0f}%) | {:.1f} FPS | Inference: {} | Gated: {}".format(
                    frame_idx, max_frames, pct, curr_fps, inference_frames, motion_gated))

            current_frame = None

    finally:
        decoder.release()
        stop_gpu_monitor()

    wall_total = time.perf_counter() - wall_start

    print("\n" + "=" * 80)
    print("  PERFORMANCE AUDIT REPORT")
    print("=" * 80)

    effective_fps = frame_idx / wall_total
    processing_ratio = wall_total / video_duration_sec if video_duration_sec > 0 else 0
    speed_mult = effective_fps / fps

    print("\n-- BASELINE METRICS --")
    print("  Frames processed:       {}".format(frame_idx))
    print("  Frames w/ inference:    {}".format(inference_frames))
    print("  Frames motion-gated:    {}".format(motion_gated))
    print("  Wall-clock time:        {:.2f}s".format(wall_total))
    print("  Effective FPS:          {:.1f}".format(effective_fps))
    print("  Speed multiplier:       {:.2f}x realtime".format(speed_mult))
    print("  Processing ratio:       {:.3f}".format(processing_ratio))

    print("\n-- STAGE-BY-STAGE TIMING (sorted by total time) --")
    report_str, stage_total = timer.report()
    print(report_str)

    print("\n-- LATENCY DISTRIBUTIONS (ms) --")
    for name, samples in [
        ("video_decode", decode_times),
        ("motion_gating", motion_gate_times),
        ("yolo_inference", yolo_times),
        ("face_detection", face_det_times),
        ("face_search", face_search_times),
    ]:
        if samples:
            arr = np.array(samples) * 1000
            print("  {:25s}  min={:.2f}ms  median={:.2f}ms  mean={:.2f}ms  p95={:.2f}ms  p99={:.2f}ms  max={:.2f}ms  total={:.3f}s  N={}".format(
                name, arr.min(), np.median(arr), arr.mean(),
                np.percentile(arr, 95), np.percentile(arr, 99),
                arr.max(), arr.sum() / 1000, len(arr)))

    print("\n-- GPU UTILIZATION SUMMARY ({} samples at ~1s) --".format(len(_gpu_samples)))
    gpu_utils = []
    mem_utils = []
    vram_used = []
    power_draws = []
    temps = []
    if _gpu_samples:
        for s in _gpu_samples:
            parts = [p.strip() for p in s.split(",")]
            if len(parts) >= 10:
                try:
                    gpu_utils.append(float(parts[1]))
                    mem_utils.append(float(parts[2]))
                    vram_used.append(float(parts[3]))
                    power_draws.append(float(parts[5]))
                    temps.append(float(parts[6]))
                except (ValueError, IndexError):
                    pass

        if gpu_utils:
            gu = np.array(gpu_utils)
            mu = np.array(mem_utils)
            vr = np.array(vram_used)
            pw = np.array(power_draws)
            tp = np.array(temps)
            print("  GPU Utilization:  min={:.0f}%  mean={:.1f}%  median={:.0f}%  p95={:.0f}%  max={:.0f}%".format(
                gu.min(), gu.mean(), np.median(gu), np.percentile(gu, 95), gu.max()))
            print("  Mem Utilization:  min={:.0f}%  mean={:.1f}%  median={:.0f}%  max={:.0f}%".format(
                mu.min(), mu.mean(), np.median(mu), mu.max()))
            print("  VRAM Used (MB):   min={:.0f}  mean={:.0f}  max={:.0f}".format(vr.min(), vr.mean(), vr.max()))
            print("  Power Draw (W):   min={:.0f}  mean={:.0f}  max={:.0f}".format(pw.min(), pw.mean(), pw.max()))
            print("  Temperature (C):  min={:.0f}  mean={:.0f}  max={:.0f}".format(tp.min(), tp.mean(), tp.max()))

            low_pct = (gu < 20).sum() / len(gu) * 100
            mid_pct = ((gu >= 20) & (gu < 60)).sum() / len(gu) * 100
            high_pct = (gu >= 60).sum() / len(gu) * 100
            print("\n  GPU Usage Pattern:")
            print("    <20%% (idle/waiting):   {:.0f}%% of time".format(low_pct))
            print("    20-60%% (partial):      {:.0f}%% of time".format(mid_pct))
            print("    >60%% (busy):           {:.0f}%% of time".format(high_pct))

    print("\n-- BOTTLENECK RANKING --")
    stage_report_data = sorted(timer.stages.items(), key=lambda x: -x[1])
    total_measured = sum(timer.stages.values())
    overhead = wall_total - total_measured

    ranking = []
    for i, (name, t) in enumerate(stage_report_data, 1):
        pct = (t / wall_total) * 100
        ranking.append((i, name, t, pct))
        print("  {}. {:40s}  {:8.3f}s  ({:5.1f}%)".format(i, name, t, pct))

    if overhead > 0.1:
        pct = (overhead / wall_total) * 100
        print("  ?. {:40s}  {:8.3f}s  ({:5.1f}%)".format("unmeasured overhead", overhead, pct))

    print("\n-- KEY OBSERVATIONS --")
    fd_total = timer.stages.get("face_detection", 0)
    yolo_total = timer.stages.get("yolo_inference", 0)
    decode_total = timer.stages.get("video_decode", 0)
    fs_total = timer.stages.get("face_search", 0)
    mg_total = timer.stages.get("motion_gating", 0)

    top_bottleneck = stage_report_data[0][0] if stage_report_data else "unknown"
    top_pct = (stage_report_data[0][1] / wall_total * 100) if stage_report_data else 0

    print("  1. PRIMARY BOTTLENECK: '{}' consuming {:.1f}%% of total time".format(top_bottleneck, top_pct))

    if fd_total > yolo_total:
        print("  2. Face detection ({:.2f}s) is SLOWER than YOLO ({:.2f}s)".format(fd_total, yolo_total))
        print("     -> InsightFace runs face detection+embedding PER PERSON PER FRAME on CPU crop")

    if motion_gated > frame_idx * 0.5:
        gated_pct = (motion_gated / frame_idx) * 100
        print("  3. Motion gating skipped {:.0f}%% of frames".format(gated_pct))

    if decode_total > wall_total * 0.15:
        print("  4. Video decoding is a significant bottleneck ({:.2f}s / {:.0f}%%)".format(
            decode_total, (decode_total / wall_total) * 100))

    if fs_total > wall_total * 0.10:
        n_enrolled = len(enrolled)
        n_encodings = sum(len(v.get("encodings", [])) for v in enrolled.values() if isinstance(v, dict))
        print("  5. Face search ({:.2f}s) iterating over {} employees x {} embeddings (brute-force CPU)".format(
            fs_total, n_enrolled, n_encodings))

    report = {
        "video": os.path.basename(video_path),
        "resolution": "{}x{}".format(width, height),
        "fps": fps,
        "total_frames": total_frames,
        "profiled_frames": frame_idx,
        "inference_frames": inference_frames,
        "motion_gated_frames": motion_gated,
        "wall_time_sec": round(wall_total, 3),
        "effective_fps": round(effective_fps, 1),
        "speed_multiplier": round(speed_mult, 2),
        "stages": {k: round(v, 4) for k, v in timer.stages.items()},
        "stage_counts": timer.counts,
        "gpu_util_mean": round(float(np.mean(gpu_utils)), 1) if gpu_utils else None,
        "gpu_util_max": round(float(np.max(gpu_utils)), 0) if gpu_utils else None,
        "bottleneck_ranking": [(name, round(t, 3), round(t / wall_total * 100, 1)) for name, t in stage_report_data],
    }

    report_path = os.path.join(os.path.dirname(__file__), "performance_audit_results.json")
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    print("\n[AUDIT] Detailed report saved to: {}".format(report_path))
    print("=" * 80)

    db.close()
    return report


if __name__ == "__main__":
    video_arg = sys.argv[1] if len(sys.argv) > 1 else None
    run_audit(video_arg)
