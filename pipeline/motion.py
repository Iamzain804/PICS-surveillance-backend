"""
Motion gating math shared by SmartVideoDecoder and the legacy (annotated-
video-output) full-decode + cv2.resize code path.

The core ratio computation (absdiff -> BGR2GRAY -> threshold ->
countNonZero) lives in ai/gpu_decoder.py as ``_motion_ratio_bgr`` because
SmartVideoDecoder needs it in its background decode thread and importing
pipeline.motion from ai.gpu_decoder would invert the package's dependency
direction (pipeline/ depends on ai/, not the other way around). This module
re-exports it under a public name and adds ``compute_motion_ratio``, which
is the exact algorithm integrated_pipeline.py used to run inline for every
frame before this refactor -- now used only by the annotated-video-output
path (SAVE_ANNOTATED_VIDEO=True), since SmartVideoDecoder performs its own
equivalent gating internally when that flag is off.

See ai/gpu_decoder.py's SmartVideoDecoder docstring for why this and the
decoder's internal thumbnail-based ratio are highly correlated but not
bit-identical, and validate_motion_gate.py for the measured agreement rate.
"""

from __future__ import annotations

import cv2
import numpy as np

from ai.gpu_decoder import _motion_ratio_bgr as motion_ratio_bgr

__all__ = ["motion_ratio_bgr", "compute_motion_ratio"]


def compute_motion_ratio(
    prev_frame_bgr: np.ndarray,
    curr_frame_bgr: np.ndarray,
    downscale_size: tuple[int, int],
    pixel_diff_thresh: int,
) -> float:
    """
    Full-resolution BGR frame pair -> cv2.resize -> motion ratio. This is
    the pre-refactor inline algorithm, preserved verbatim for the
    annotated-video code path where every frame is already fully decoded
    regardless of motion.
    """
    small_prev = cv2.resize(prev_frame_bgr, downscale_size)
    small_curr = cv2.resize(curr_frame_bgr, downscale_size)
    return motion_ratio_bgr(small_prev, small_curr, pixel_diff_thresh)
