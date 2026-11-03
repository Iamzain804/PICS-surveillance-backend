"""
EPIC Integrated AI Pipeline -- backward-compatibility shim.
=============================================================
The real implementation now lives in the ``pipeline`` package
(pipeline/config.py, decoder.py, motion.py, detector.py, tracker.py,
recognizer.py, matcher.py, checkpoint.py, timestamps.py, video_io.py,
pipeline.py, benchmark.py). This module exists only because 15+ files
across the codebase import directly from ``integrated_pipeline``
(api_server.py, celery_app.py, parallel_runner.py, demo_workflow.py,
run_demo_chunks.py, run_demo_reprocess.py, main.py, performance_audit.py,
performance_audit_smart.py, ab_benchmark_suite.py, benchmark_prefetch.py,
and three test modules) -- rewriting every one of those call sites carried
far more regression risk than keeping this thin re-export layer.

New code should import from ``pipeline.*`` directly instead of from here.

Module-level constants below (FRAME_SAMPLE_INTERVAL, MOTION_THRESHOLD_RATIO,
etc.) are resolved once at import time from PipelineConfig, exactly as they
used to be resolved once at import time from config.settings.cfg -- same
timing, same values, same names.
"""

from typing import Any, Dict, Optional

from ai.gpu_decoder import NVDECGPUVideoDecoder, PrefetchedGPUVideoDecoder, SmartVideoDecoder
from pipeline.checkpoint import load_checkpoint, save_checkpoint
from pipeline.config import PipelineConfig, load_pipeline_config
from pipeline.detector import get_yolo_model
from pipeline.matcher import build_enrollment_matrix, search_with_margin
from pipeline.matcher import load_enrolled_employees as _load_enrolled_employees
from pipeline.pipeline import process_video_single_pass, run_integrated_pipeline
from pipeline.recognizer import check_face_quality_gate, compute_face_quality, get_insightface_app
from pipeline.timestamps import TimestampDriftCorrector, calculate_real_timestamp, parse_video_start_time
from pipeline.video_io import (
    create_nvenc_writer,
    create_video_writer as _create_video_writer,
    draw_hud,
    get_ffmpeg_executable,
    release_video_writer,
    resolve_video_input_path as _resolve_video_input_path,
    resolve_video_output_path as _resolve_video_output_path,
    write_video_frame,
)

_shim_config: PipelineConfig = load_pipeline_config()

# ==================== BACKWARD-COMPATIBLE MODULE CONSTANTS ====================
YOLO_ENGINE_PATH = _shim_config.resolved_yolo_engine_path()
YOLO_MODEL_PATH = _shim_config.resolved_yolo_model_path()
PERSON_CLASS_ID = _shim_config.person_class_id
CONFIDENCE_THRESHOLD = _shim_config.confidence_threshold

ENCODINGS_PKL_PATH = _shim_config.resolved_encodings_pkl_path()
RECOGNITION_THRESHOLD = _shim_config.recognition_threshold
MAX_FACE_SAMPLES_LOCK = _shim_config.max_face_samples_lock
MAX_FACE_ATTEMPTS_LOCK = _shim_config.max_face_attempts_lock

FRAME_SAMPLE_INTERVAL = _shim_config.frame_sample_interval

MOTION_THRESHOLD_RATIO = _shim_config.motion_threshold_ratio
MOTION_PIXEL_DIFF_THRESH = _shim_config.motion_pixel_diff_thresh
MOTION_DOWNSCALE_SIZE = _shim_config.motion_downscale_size
TRACK_LOST_MAX_FRAMES = _shim_config.track_lost_max_frames

SAVE_ANNOTATED_VIDEO = _shim_config.save_annotated_video
# ================================================================================


def load_enrolled_employees(pkl_path: str = ENCODINGS_PKL_PATH) -> Dict[str, Any]:
    """Same zero-arg-callable contract as before: defaults to the configured encodings.pkl path."""
    return _load_enrolled_employees(pkl_path, backend_dir=_shim_config.backend_dir)


def resolve_video_input_path(video_record: Any) -> str:
    return _resolve_video_input_path(video_record, _shim_config.backend_dir)


def resolve_video_output_path(video_record: Any, output_base_dir: Optional[str] = None) -> str:
    return _resolve_video_output_path(video_record, _shim_config.backend_dir, output_base_dir)


def create_video_writer(output_path: str, width: int, height: int, fps: float, force_gpu: bool = True):
    return _create_video_writer(output_path, width, height, fps, save_annotated_video=SAVE_ANNOTATED_VIDEO, force_gpu=force_gpu)


__all__ = [
    "NVDECGPUVideoDecoder", "PrefetchedGPUVideoDecoder", "SmartVideoDecoder",
    "get_yolo_model", "get_insightface_app",
    "load_enrolled_employees", "build_enrollment_matrix", "search_with_margin",
    "check_face_quality_gate", "compute_face_quality",
    "save_checkpoint", "load_checkpoint",
    "TimestampDriftCorrector", "parse_video_start_time", "calculate_real_timestamp",
    "draw_hud", "get_ffmpeg_executable", "create_nvenc_writer",
    "create_video_writer", "write_video_frame", "release_video_writer",
    "resolve_video_input_path", "resolve_video_output_path",
    "process_video_single_pass", "run_integrated_pipeline",
    "YOLO_ENGINE_PATH", "YOLO_MODEL_PATH", "PERSON_CLASS_ID", "CONFIDENCE_THRESHOLD",
    "ENCODINGS_PKL_PATH", "RECOGNITION_THRESHOLD", "MAX_FACE_SAMPLES_LOCK", "MAX_FACE_ATTEMPTS_LOCK",
    "FRAME_SAMPLE_INTERVAL", "MOTION_THRESHOLD_RATIO", "MOTION_PIXEL_DIFF_THRESH",
    "MOTION_DOWNSCALE_SIZE", "TRACK_LOST_MAX_FRAMES", "SAVE_ANNOTATED_VIDEO",
]


if __name__ == "__main__":
    run_integrated_pipeline()
