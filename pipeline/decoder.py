"""
Video decoder classes for the single-pass pipeline.

The real implementation lives in ai/gpu_decoder.py -- that module predates
this refactor and is imported directly by five other files across the
codebase (ai/tracker_engine.py, ai/ocr_extractor.py, ai/__init__.py, and two
standalone benchmark scripts), so it was not moved. This module re-exports
the same classes so pipeline/*.py has its own decoder.py per the package
layout, and so pipeline code never has to reach outside the package for its
decoder.

All three classes support the context-manager protocol::

    with SmartVideoDecoder(video_path, queue_size=6) as decoder:
        ok, frame, motion_ratio = decoder.read()
        ...
    # decoder.release() is called automatically, even on exception
"""

from ai.gpu_decoder import (
    NVDECGPUVideoDecoder,
    PrefetchedGPUVideoDecoder,
    SmartVideoDecoder,
)

__all__ = ["NVDECGPUVideoDecoder", "PrefetchedGPUVideoDecoder", "SmartVideoDecoder"]
