"""
YOLOv8 person detector, wrapping Ultralytics' YOLO.track().

Model loading priority (unchanged from the original integrated_pipeline.py):
  1. TensorRT FP16 engine (models/yolov8n.engine) -- 2-4x faster than PyTorch
  2. PyTorch GPU weights (models/yolov8n.pt) -- automatic fallback
  3. Bare ultralytics default ("yolov8n.pt", triggers an implicit download)

ByteTrack itself is not a separate object in this codebase: Ultralytics'
YOLO.track(persist=True) owns the tracker internally and keeps its state on
the YOLO model instance across calls. pipeline/tracker.py wraps the
*consumer-side* bookkeeping (active bboxes, last-seen frame, stale-track
cleanup) that integrated_pipeline.py used to keep as loose local
dictionaries in the main loop.
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Optional

import numpy as np

from pipeline.config import PipelineConfig, load_pipeline_config
from pipeline.logging_setup import get_logger

logger = get_logger("detector")

_SHARED_YOLO_MODEL = None


@dataclass(frozen=True)
class TrackedDetection:
    """One person detection with its ByteTrack-assigned track id."""
    track_id: int
    x1: int
    y1: int
    x2: int
    y2: int

    @property
    def bbox(self) -> tuple[int, int, int, int]:
        return (self.x1, self.y1, self.x2, self.y2)


def get_yolo_model(model_path: Optional[str] = None, config: Optional[PipelineConfig] = None):
    """
    Lazy-load YOLO model singleton with priority:
    1. TensorRT FP16 Engine (models/yolov8n.engine) - 2-4x faster than PyTorch
    2. PyTorch GPU Weights (models/yolov8n.pt) - automatic fallback

    Kept as a free function (not just a method) because several other
    modules across the codebase call this directly expecting the same
    process-wide singleton (ab_benchmark_suite.py, performance_audit.py,
    demo_workflow.py, ...).
    """
    global _SHARED_YOLO_MODEL
    if _SHARED_YOLO_MODEL is not None:
        return _SHARED_YOLO_MODEL

    from ultralytics import YOLO

    conf = config or load_pipeline_config()
    backend_dir = conf.backend_dir

    engine_candidates = [
        model_path if (model_path and model_path.endswith(".engine")) else None,
        conf.resolved_yolo_engine_path(),
        os.path.join(backend_dir, "yolov8n.engine"),
        "yolov8n.engine",
    ]

    loaded = False
    for eng_path in filter(None, engine_candidates):
        if os.path.exists(eng_path):
            try:
                logger.info("Loading TensorRT FP16 engine: %s", eng_path)
                _SHARED_YOLO_MODEL = YOLO(eng_path, task="detect")
                loaded = True
                break
            except Exception as e:
                logger.warning("Failed loading TensorRT engine (%s): %s -- trying next candidate", eng_path, e)

    if not loaded:
        pt_candidates = [
            model_path if (model_path and model_path.endswith(".pt")) else None,
            conf.resolved_yolo_model_path(),
            os.path.join(backend_dir, "yolov8n.pt"),
            "yolov8n.pt",
        ]
        for pt_path in filter(None, pt_candidates):
            if os.path.exists(pt_path):
                try:
                    logger.warning("TensorRT engine unavailable -- loading PyTorch GPU model (fallback): %s", pt_path)
                    _SHARED_YOLO_MODEL = YOLO(pt_path)
                    loaded = True
                    break
                except Exception as e:
                    logger.warning("Failed loading PyTorch model (%s): %s", pt_path, e)

    if not loaded:
        logger.warning("No local YOLO weights found -- loading default YOLO('yolov8n.pt') (may trigger a download)")
        _SHARED_YOLO_MODEL = YOLO("yolov8n.pt")

    return _SHARED_YOLO_MODEL


class YoloDetector:
    """Thin OO wrapper around get_yolo_model() + YOLO.track(), parsing
    raw Ultralytics results into typed TrackedDetection objects."""

    def __init__(self, config: Optional[PipelineConfig] = None) -> None:
        self.config = config or load_pipeline_config()
        self._model = None

    @property
    def model(self):
        if self._model is None:
            self._model = get_yolo_model(config=self.config)
        return self._model

    def track(self, frame: np.ndarray) -> list[TrackedDetection]:
        """Runs YOLO detection + ByteTrack association on one frame."""
        results = self.model.track(
            source=frame,
            persist=True,
            classes=[self.config.person_class_id],
            conf=self.config.confidence_threshold,
            verbose=False,
        )

        detections: list[TrackedDetection] = []
        if results and len(results) > 0 and results[0].boxes is not None:
            boxes = results[0].boxes
            if boxes.id is not None:
                track_ids = boxes.id.cpu().numpy().astype(int)
                xyxy_boxes = boxes.xyxy.cpu().numpy()
                for box, track_id in zip(xyxy_boxes, track_ids):
                    x1, y1, x2, y2 = map(int, box)
                    detections.append(TrackedDetection(track_id=int(track_id), x1=x1, y1=y1, x2=x2, y2=y2))
        return detections
