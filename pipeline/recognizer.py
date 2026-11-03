"""
InsightFace (buffalo_l) face detection + embedding wrapper.

get_insightface_app() keeps the same process-wide singleton and GPU/CPU
fallback chain the original integrated_pipeline.py had: CUDA execution
provider with a pre-warmed cuDNN engine, falling back to CPU-only if CUDA
init fails, falling back to a larger det_size CPU-only path if even that
fails to construct. If InsightFace itself isn't installed or the buffalo_l
model files are missing, this now raises a clear, explicit error (Objective
2 requirement) instead of leaving a confusing AttributeError further down
the pipeline.
"""

from __future__ import annotations

from typing import Any

import numpy as np

from pipeline.logging_setup import get_logger

logger = get_logger("recognizer")

_SHARED_INSIGHTFACE_APP = None


class InsightFaceUnavailableError(RuntimeError):
    """Raised when InsightFace cannot be initialized in any configuration
    (package missing, buffalo_l model files missing/corrupt, or no usable
    ONNX Runtime execution provider)."""


def get_insightface_app() -> Any:
    """Lazy-load InsightFace buffalo_l model singleton with GPU VRAM memory limit."""
    global _SHARED_INSIGHTFACE_APP
    if _SHARED_INSIGHTFACE_APP is not None:
        return _SHARED_INSIGHTFACE_APP

    providers: list[str] = []
    try:
        import onnxruntime as ort
        providers = ort.get_available_providers()
        logger.info("ONNX providers available: %s", providers)
    except Exception as provider_err:
        logger.warning("Could not query ONNX providers: %s", provider_err)

    try:
        from insightface.app import FaceAnalysis
    except ImportError as e:
        raise InsightFaceUnavailableError(
            "The 'insightface' package is not installed. Install it with "
            "`pip install insightface` and ensure the buffalo_l model files "
            "are present under ~/.insightface/models/buffalo_l/."
        ) from e

    if "CUDAExecutionProvider" in providers:
        try:
            import torch
            if torch.cuda.is_available():
                torch.backends.cudnn.benchmark = True
                if hasattr(torch.backends.cuda.matmul, "allow_tf32"):
                    torch.backends.cuda.matmul.allow_tf32 = True
                if hasattr(torch.backends.cudnn, "allow_tf32"):
                    torch.backends.cudnn.allow_tf32 = True
        except Exception:
            pass

        cuda_provider_options = {
            "device_id": 0,
            "arena_extend_strategy": "kNextPowerOfTwo",
            "cudnn_conv_algo_search": "EXHAUSTIVE",
            "do_copy_in_default_stream": 1,
        }
        cuda_providers = [("CUDAExecutionProvider", cuda_provider_options), "CPUExecutionProvider"]
        try:
            app = FaceAnalysis(name="buffalo_l", allowed_modules=["detection", "recognition"], providers=cuda_providers)
            app.prepare(ctx_id=0, det_size=(320, 320), det_thresh=0.15)
            # Pre-warm GPU cuDNN engine to eliminate first-frame cold start spike
            dummy_crop = np.zeros((320, 320, 3), dtype=np.uint8)
            app.get(dummy_crop)
            _SHARED_INSIGHTFACE_APP = app
            logger.info("Initialized & pre-warmed InsightFace buffalo_l (CUDA, det_size=320x320)")
            return _SHARED_INSIGHTFACE_APP
        except Exception as cuda_err:
            logger.warning("CUDA initialization failed (%s), retrying CPU-only fallback.", cuda_err)

    try:
        app = FaceAnalysis(name="buffalo_l", allowed_modules=["detection", "recognition"], providers=["CPUExecutionProvider"])
        app.prepare(ctx_id=-1, det_size=(320, 320), det_thresh=0.15)
        _SHARED_INSIGHTFACE_APP = app
        logger.info("Initialized InsightFace buffalo_l (CPU-only, det_size=320x320)")
        return _SHARED_INSIGHTFACE_APP
    except Exception as e:
        logger.warning("Standard InsightFace initialization failed (%s). Trying CPU-only large-det_size fallback.", e)
        try:
            app = FaceAnalysis(name="buffalo_l", providers=["CPUExecutionProvider"])
            app.prepare(ctx_id=0, det_size=(640, 640), det_thresh=0.15)
            _SHARED_INSIGHTFACE_APP = app
            logger.info("Initialized InsightFace buffalo_l (CPU-only, det_size=640x640 fallback)")
            return _SHARED_INSIGHTFACE_APP
        except Exception as cpu_err:
            raise InsightFaceUnavailableError(
                f"InsightFace buffalo_l could not be initialized on any provider "
                f"(CUDA error was suppressed above; final CPU fallback error: {cpu_err}). "
                f"Verify the buffalo_l model files exist under ~/.insightface/models/buffalo_l/."
            ) from cpu_err


def compute_face_quality(face: Any) -> float:
    """Quality metric for a detected face using bbox area, det score, and pose symmetry."""
    score = getattr(face, "det_score", 0.0) or 0.5
    bbox = face.bbox
    w = max(1.0, float(bbox[2] - bbox[0]))
    h = max(1.0, float(bbox[3] - bbox[1]))
    area = w * h

    symmetry_factor = 1.0
    if hasattr(face, "kps") and face.kps is not None and len(face.kps) >= 5:
        kps = face.kps
        left_eye, right_eye, nose = kps[0], kps[1], kps[2]
        eye_dist = np.linalg.norm(right_eye - left_eye)
        if eye_dist > 5:
            eye_mid = (left_eye + right_eye) / 2.0
            nose_offset = float(np.linalg.norm(nose - eye_mid) / eye_dist)
            symmetry_factor = max(0.2, 1.0 - abs(nose_offset - 0.5))

    return float(area * score * symmetry_factor)


def check_face_quality_gate(face: Any) -> bool:
    """Quality gate for CCTV surveillance cameras: accepts any face with minimum valid dimensions."""
    bbox = getattr(face, "bbox", None)
    if bbox is None:
        return False
    w = float(bbox[2] - bbox[0])
    h = float(bbox[3] - bbox[1])
    if w < 15.0 or h < 15.0:
        return False
    return True


class FaceRecognizer:
    """OO wrapper around get_insightface_app() for pipeline/pipeline.py."""

    def __init__(self) -> None:
        self._app = None

    @property
    def app(self) -> Any:
        if self._app is None:
            self._app = get_insightface_app()
        return self._app

    def detect(self, person_crop: np.ndarray) -> list[Any]:
        """Runs face detection+embedding on a person crop, returning raw
        InsightFace Face objects (quality-gated by the caller)."""
        try:
            return self.app.get(person_crop) or []
        except Exception as e:
            logger.debug("Face detection failed on a crop: %s", e)
            return []
