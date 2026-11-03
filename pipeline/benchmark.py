"""
Reusable, config-driven benchmark runner.

This is the canonical successor to the duplicated profiling loops in
performance_audit.py and performance_audit_smart.py (kept in place as
legacy references per project instructions, not deleted). Unlike those two
scripts, this one is parameterized by PipelineConfig and decoder choice
instead of hardcoding one or the other, so ``cli.py --benchmark`` and any
future caller share one implementation instead of three.

It intentionally does NOT call pipeline.pipeline.process_video_single_pass
directly: that function's DB writes (Event/ReviewQueue rows, staff lookups,
checkpoint files) are real production side effects with no "dry run" flag,
and threading one through ~700 lines of transaction-sensitive code is a
correctness risk this refactor's own "do not change core behavior"
constraint argues against taking on. Instead this reimplements the same
decode -> motion-gate -> YOLO+ByteTrack -> face-detect -> face-search loop
structure using the same shared components (pipeline.detector,
pipeline.recognizer, pipeline.matcher, pipeline.decoder) that
process_video_single_pass uses, with DB/video-writer/OCR side effects left
out entirely -- exactly what performance_audit.py and
performance_audit_smart.py already did by hand, just unified and reusable.
"""

from __future__ import annotations

import time
from typing import Any, Literal, Optional, Union

import numpy as np

from pipeline.config import PipelineConfig, load_pipeline_config
from pipeline.decoder import PrefetchedGPUVideoDecoder, SmartVideoDecoder
from pipeline.detector import YoloDetector
from pipeline.logging_setup import get_logger
from pipeline.matcher import load_enrolled_employees, search_with_margin
from pipeline.motion import compute_motion_ratio
from pipeline.recognizer import FaceRecognizer, check_face_quality_gate, compute_face_quality

logger = get_logger("benchmark")

DecoderMode = Literal["auto", "smart", "legacy"]


class StageTimer:
    """Same accumulate-by-name timer shape as performance_audit.py's, so
    results are directly comparable."""

    def __init__(self) -> None:
        self.stages: dict[str, float] = {}
        self._active: dict[str, float] = {}
        self.counts: dict[str, int] = {}

    def start(self, name: str) -> None:
        self._active[name] = time.perf_counter()

    def stop(self, name: str) -> float:
        if name in self._active:
            dt = time.perf_counter() - self._active.pop(name)
            self.stages[name] = self.stages.get(name, 0.0) + dt
            self.counts[name] = self.counts.get(name, 0) + 1
            return dt
        return 0.0


def run_benchmark(
    video_path: str,
    config: Optional[PipelineConfig] = None,
    decoder_mode: DecoderMode = "auto",
    max_frames: int = 5000,
) -> dict[str, Any]:
    """
    Runs the decode -> motion-gate -> YOLO/ByteTrack -> face-recognition
    loop on ``video_path`` for up to ``max_frames`` frames, with no DB or
    video-output side effects, and returns stage timings + throughput.

    decoder_mode:
      "auto"   -- SmartVideoDecoder if config.save_annotated_video is False
                  (matches what process_video_single_pass would actually use)
      "smart"  -- force SmartVideoDecoder regardless of config
      "legacy" -- force PrefetchedGPUVideoDecoder + inline cv2 motion gate
    """
    conf = config or load_pipeline_config()
    timer = StageTimer()

    detector = YoloDetector(conf)
    recognizer = FaceRecognizer()
    enrolled = load_enrolled_employees(conf.resolved_encodings_pkl_path(), backend_dir=conf.backend_dir)

    use_smart = (decoder_mode == "smart") or (decoder_mode == "auto" and not conf.save_annotated_video)

    timer.start("model_load_yolo")
    _ = detector.model
    timer.stop("model_load_yolo")

    timer.start("model_load_insightface")
    _ = recognizer.app
    timer.stop("model_load_insightface")

    timer.start("video_open")
    decoder: Union[SmartVideoDecoder, PrefetchedGPUVideoDecoder]
    if use_smart:
        decoder = SmartVideoDecoder(
            video_path, queue_size=conf.queue_size, downscale_size=conf.motion_downscale_size,
            motion_threshold_ratio=conf.motion_threshold_ratio, motion_pixel_diff_thresh=conf.motion_pixel_diff_thresh,
        )
    else:
        decoder = PrefetchedGPUVideoDecoder(video_path, queue_size=conf.queue_size)
    timer.stop("video_open")

    width, height = decoder.width, decoder.height
    fps = max(float(decoder.fps), 1.0)
    total_frames = int(decoder.total_frames)
    max_frames = min(total_frames, max_frames) if total_frames > 0 else max_frames

    track_cache: dict[int, dict[str, Any]] = {}
    active_last_seen: dict[int, int] = {}

    prev_frame: Optional[np.ndarray] = None
    current_frame: Optional[np.ndarray] = None
    frame_idx = 0
    motion_gated = 0
    inference_frames = 0

    logger.info("Benchmarking %s | decoder=%s | max_frames=%d", video_path, "smart" if use_smart else "legacy", max_frames)

    wall_start = time.perf_counter()
    try:
        while frame_idx < max_frames:
            if current_frame is None:
                timer.start("video_decode")
                read_res = decoder.read()
                ret = read_res[0]
                current_frame = read_res[1] if ret else None
                timer.stop("video_decode")
                if not ret:
                    break

            frame_idx += 1

            if use_smart:
                if current_frame is None:
                    motion_gated += 1
                    current_frame = None
                    continue
            else:
                # In the else (legacy/PrefetchedGPUVideoDecoder) branch,
                # current_frame is never None here -- only SmartVideoDecoder
                # produces None frames, and use_smart is False on this path.
                # mypy can't infer that from the type alone.
                assert current_frame is not None
                if prev_frame is not None:
                    timer.start("motion_gating")
                    ratio = compute_motion_ratio(prev_frame, current_frame, conf.motion_downscale_size, conf.motion_pixel_diff_thresh)
                    timer.stop("motion_gating")
                    if ratio < conf.motion_threshold_ratio:
                        motion_gated += 1
                        current_frame = None
                        continue
                prev_frame = current_frame.copy()

            assert current_frame is not None
            inference_frames += 1

            timer.start("yolo_inference")
            detections = detector.track(current_frame)
            timer.stop("yolo_inference")

            timer.start("yolo_postprocess")
            for det in detections:
                active_last_seen[det.track_id] = frame_idx
                if det.track_id not in track_cache:
                    track_cache[det.track_id] = {"attempts": 0, "face_samples": [], "locked": False}
                cache = track_cache[det.track_id]
                if cache["locked"]:
                    continue

                x1, y1, x2, y2 = det.bbox
                crop = current_frame[max(0, y1):min(height, y2), max(0, x1):min(width, x2)]
                if crop.size > 0 and crop.shape[0] >= 30 and crop.shape[1] >= 30:
                    timer.start("face_detection")
                    faces = recognizer.detect(crop)
                    cache["attempts"] += 1
                    for face in faces:
                        if check_face_quality_gate(face):
                            cache["face_samples"].append((compute_face_quality(face), face))
                    timer.stop("face_detection")

                if cache["face_samples"]:
                    timer.start("face_search")
                    best_sim = 0.0
                    best_id = None
                    for _, face in cache["face_samples"]:
                        top1_id, top1_sim, _, _ = search_with_margin(face, enrolled)
                        if top1_id and top1_sim > best_sim:
                            best_sim, best_id = top1_sim, top1_id
                    if best_id and best_sim >= conf.recognition_lock_threshold:
                        cache["locked"] = True
                    elif cache["attempts"] >= conf.max_face_attempts_lock:
                        cache["locked"] = True
                    timer.stop("face_search")
            timer.stop("yolo_postprocess")

            timer.start("track_cleanup")
            lost = [tid for tid, lf in active_last_seen.items() if (frame_idx - lf) > 30]
            for tid in lost:
                active_last_seen.pop(tid, None)
                track_cache.pop(tid, None)
            timer.stop("track_cleanup")

            current_frame = None
    finally:
        # Deliberately NOT `with decoder:` here. During Objective 2
        # validation, using the context-manager form specifically with
        # SmartVideoDecoder on a full-scale run (~450+ inference calls) was
        # observed to hang the process indefinitely *after* all real work
        # (including decoder.release() itself) had already completed and
        # logged -- confirmed via direct process inspection (py-spy could not
        # attach without elevated Windows privileges to get a stack trace).
        # Confirmed to disappear when replaced with this identical-effect
        # explicit try/finally; PrefetchedGPUVideoDecoder via `with` was not
        # affected. The mechanism was not fully root-caused (both forms call
        # the exact same release() method), so treat
        # `with SmartVideoDecoder(...)` as unverified for long/high-frame-count
        # runs until that's understood -- this explicit form is proven safe
        # across repeated 5,000-frame runs.
        decoder.release()

    wall_total = time.perf_counter() - wall_start
    effective_fps = frame_idx / wall_total if wall_total > 0 else 0.0

    result = {
        "video": video_path,
        "decoder_mode": "smart" if use_smart else "legacy",
        "resolution": f"{width}x{height}",
        "fps": fps,
        "total_frames": total_frames,
        "profiled_frames": frame_idx,
        "inference_frames": inference_frames,
        "motion_gated_frames": motion_gated,
        "wall_time_sec": round(wall_total, 3),
        "effective_fps": round(effective_fps, 1),
        "speed_multiplier": round(effective_fps / fps, 2) if fps else 0.0,
        "stages": {k: round(v, 4) for k, v in timer.stages.items()},
        "stage_counts": timer.counts,
    }

    logger.info(
        "Benchmark done: %d frames in %.2fs (%.1f FPS, %.2fx realtime) | inference=%d gated=%d",
        frame_idx, wall_total, effective_fps, result["speed_multiplier"], inference_frames, motion_gated,
    )
    return result
