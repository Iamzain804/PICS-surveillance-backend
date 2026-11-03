"""
EPIC single-pass video pipeline, modularised.

Historically all of this lived in one file, ``integrated_pipeline.py``. That
module now re-exports everything from here for backward compatibility (15+
call sites across the codebase import from it directly), but this package is
the real implementation going forward.
"""
