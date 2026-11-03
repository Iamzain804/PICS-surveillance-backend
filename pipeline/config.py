"""
PipelineConfig: a single, typed source of truth for every tunable the
single-pass pipeline used to read as a scattered module-level constant in
integrated_pipeline.py.

Resolution order (highest priority wins), matching what the old module-level
constants already did via config.settings.cfg, plus two new layers on top:

    CLI overrides  >  environment variables  >  config/config.yaml  >  dataclass default

Values are loaded through config.settings.cfg (the existing YAML+env loader
used across the rest of the backend) so config/config.yaml stays the single
YAML source of truth -- this module does not parse YAML itself.

Two groups of fields are worth flagging explicitly:

  - ``recognition_threshold`` and ``max_face_samples_lock`` are read from
    config.yaml's ``face_recognition`` section but were never actually
    consulted by the matching logic in integrated_pipeline.py -- the real
    decisions used hardcoded literals. They are kept here for backward
    compatibility (other modules read the old module-level constants) but
    are dead as far as the pipeline's own behavior is concerned.
  - ``recognition_lock_threshold`` (0.44), ``ambiguous_threshold`` (0.40),
    ``ambiguous_margin`` (0.03), ``attendance_cooldown_seconds`` (30.0), and
    ``post_detection_stale_frames`` (30) were previously bare numeric
    literals inline in the loop. They are now real config fields, but their
    defaults are set to the exact values already in effect so behavior is
    unchanged -- see pipeline/pipeline.py for where each was hardcoded
    before this refactor.
"""

from __future__ import annotations

import argparse
import os
from dataclasses import dataclass
from typing import Any, Optional

try:
    from config.settings import cfg as _yaml_cfg
except ImportError:
    _yaml_cfg = {}

_BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


@dataclass
class PipelineConfig:
    backend_dir: str = _BACKEND_DIR

    # -- YOLO detection --------------------------------------------------
    yolo_engine_path: str = os.path.join("models", "yolov8n.engine")
    yolo_model_path: str = os.path.join("models", "yolov8n.pt")
    person_class_id: int = 0
    confidence_threshold: float = 0.30

    # -- Face recognition --------------------------------------------------
    encodings_pkl_path: str = os.path.join("ai", "encoding", "encodings.pkl")
    recognition_threshold: float = 0.46  # declared, not consulted -- see module docstring
    max_face_samples_lock: int = 5       # declared, not consulted -- see module docstring
    max_face_attempts_lock: int = 50
    recognition_lock_threshold: float = 0.44
    ambiguous_threshold: float = 0.40
    ambiguous_margin: float = 0.03
    ambiguous_display_threshold: float = 0.42  # min similarity to list a candidate name in an ambiguous event

    # -- Frame sampling / motion gating ------------------------------------
    frame_sample_interval: int = 1
    motion_threshold_ratio: float = 0.005
    motion_pixel_diff_thresh: int = 20
    motion_downscale_size: tuple[int, int] = (160, 120)
    track_lost_max_frames: int = 100
    post_detection_stale_frames: int = 30

    # -- Video output --------------------------------------------------
    save_annotated_video: bool = False

    # -- Decoder --------------------------------------------------
    queue_size: int = 6
    enable_async_decode: bool = True
    enable_tensorrt: bool = True

    # -- Attendance logic --------------------------------------------------
    attendance_cooldown_seconds: float = 30.0

    # -- Logging --------------------------------------------------
    log_level: str = "INFO"

    def resolved_yolo_engine_path(self) -> str:
        return self.yolo_engine_path if os.path.isabs(self.yolo_engine_path) else os.path.join(self.backend_dir, self.yolo_engine_path)

    def resolved_yolo_model_path(self) -> str:
        return self.yolo_model_path if os.path.isabs(self.yolo_model_path) else os.path.join(self.backend_dir, self.yolo_model_path)

    def resolved_encodings_pkl_path(self) -> str:
        return self.encodings_pkl_path if os.path.isabs(self.encodings_pkl_path) else os.path.join(self.backend_dir, self.encodings_pkl_path)


# Environment variables this loader additionally honors, beyond the ones
# config.settings._apply_env_overrides already folds into cfg (DATABASE_URL,
# RECOGNITION_THRESHOLD, MOTION_THRESHOLD_RATIO, ...). Kept small and
# specific to fields that make sense to flip per-run/per-environment.
_ENV_OVERRIDES: dict[str, str] = {
    "PIPELINE_CONFIDENCE_THRESHOLD": "confidence_threshold",
    "PIPELINE_QUEUE_SIZE": "queue_size",
    "PIPELINE_SAVE_ANNOTATED_VIDEO": "save_annotated_video",
    "PIPELINE_LOG_LEVEL": "log_level",
    "PIPELINE_FRAME_SAMPLE_INTERVAL": "frame_sample_interval",
}


def _coerce(raw: str, current: Any) -> Any:
    if isinstance(current, bool):
        return raw.strip().lower() in ("1", "true", "yes", "on")
    if isinstance(current, int):
        return int(raw)
    if isinstance(current, float):
        return float(raw)
    return raw


def load_pipeline_config(overrides: Optional[dict[str, Any]] = None) -> PipelineConfig:
    """
    Build a PipelineConfig from config/config.yaml (via config.settings.cfg),
    then environment variables, then explicit ``overrides`` (e.g. from argparse).
    """
    yolo_cfg = _yaml_cfg.get("yolo", {})
    face_cfg = _yaml_cfg.get("face_recognition", {})
    sampling_cfg = _yaml_cfg.get("sampling", {})
    motion_cfg = _yaml_cfg.get("motion_gating", {})
    video_out_cfg = _yaml_cfg.get("video_output", {})
    logging_cfg = _yaml_cfg.get("logging", {})

    downscale = motion_cfg.get("downscale_size", [160, 120])
    downscale_size = (int(downscale[0]), int(downscale[1])) if isinstance(downscale, (list, tuple)) else (160, 120)

    conf = PipelineConfig(
        yolo_engine_path=yolo_cfg.get("engine_path", PipelineConfig.yolo_engine_path),
        yolo_model_path=yolo_cfg.get("model_path", PipelineConfig.yolo_model_path),
        person_class_id=int(yolo_cfg.get("person_class_id", 0)),
        confidence_threshold=float(yolo_cfg.get("confidence_threshold", 0.30)),
        encodings_pkl_path=face_cfg.get("encodings_pkl_path", PipelineConfig.encodings_pkl_path),
        recognition_threshold=float(face_cfg.get("recognition_threshold", 0.46)),
        max_face_samples_lock=int(face_cfg.get("max_face_samples_lock", 5)),
        max_face_attempts_lock=int(face_cfg.get("max_face_attempts_lock", 50)),
        recognition_lock_threshold=float(face_cfg.get("recognition_lock_threshold", 0.44)),
        ambiguous_threshold=float(face_cfg.get("ambiguous_threshold", 0.40)),
        ambiguous_margin=float(face_cfg.get("ambiguous_margin", 0.03)),
        ambiguous_display_threshold=float(face_cfg.get("ambiguous_display_threshold", 0.42)),
        frame_sample_interval=int(sampling_cfg.get("frame_sample_interval", 1)),
        motion_threshold_ratio=float(motion_cfg.get("threshold_ratio", 0.005)),
        motion_pixel_diff_thresh=int(motion_cfg.get("pixel_diff_threshold", 20)),
        motion_downscale_size=downscale_size,
        track_lost_max_frames=int(motion_cfg.get("track_lost_max_frames", 100)),
        post_detection_stale_frames=int(motion_cfg.get("post_detection_stale_frames", 30)),
        save_annotated_video=bool(video_out_cfg.get("save_annotated_video", False)),
        queue_size=int(_yaml_cfg.get("decoder", {}).get("queue_size", 6)),
        enable_async_decode=bool(_yaml_cfg.get("decoder", {}).get("enable_async_decode", True)),
        enable_tensorrt=bool(_yaml_cfg.get("decoder", {}).get("enable_tensorrt", True)),
        attendance_cooldown_seconds=float(_yaml_cfg.get("attendance", {}).get("cooldown_seconds", 30.0)),
        log_level=str(logging_cfg.get("level", "INFO")),
    )

    for env_key, field_name in _ENV_OVERRIDES.items():
        raw = os.environ.get(env_key)
        if raw is not None:
            setattr(conf, field_name, _coerce(raw, getattr(conf, field_name)))

    if overrides:
        for key, value in overrides.items():
            if value is not None and hasattr(conf, key):
                setattr(conf, key, value)

    return conf


def add_config_cli_arguments(parser: argparse.ArgumentParser) -> None:
    """Registers --set-style overrides for the most commonly tuned fields."""
    parser.add_argument("--confidence-threshold", type=float, default=None, help="YOLO detection confidence threshold")
    parser.add_argument("--motion-threshold-ratio", type=float, default=None, help="Motion gating ratio threshold")
    parser.add_argument("--frame-sample-interval", type=int, default=None, help="Process every Nth frame")
    parser.add_argument("--queue-size", type=int, default=None, help="Decoder prefetch queue depth")
    parser.add_argument("--save-annotated-video", action="store_true", default=None, help="Enable annotated video output (forces full decode every frame)")
    parser.add_argument("--log-level", type=str, default=None, choices=["DEBUG", "INFO", "WARNING", "ERROR"], help="Logging verbosity")


def cli_args_to_overrides(args: argparse.Namespace) -> dict[str, Any]:
    mapping = {
        "confidence_threshold": getattr(args, "confidence_threshold", None),
        "motion_threshold_ratio": getattr(args, "motion_threshold_ratio", None),
        "frame_sample_interval": getattr(args, "frame_sample_interval", None),
        "queue_size": getattr(args, "queue_size", None),
        "save_annotated_video": getattr(args, "save_annotated_video", None),
        "log_level": getattr(args, "log_level", None),
    }
    return {k: v for k, v in mapping.items() if v is not None}
