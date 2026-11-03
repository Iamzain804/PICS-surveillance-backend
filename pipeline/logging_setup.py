"""
Structured logging for the pipeline package.

This is deliberately separate from the existing root-level ``logger.py``,
which writes an application audit trail into the ``SystemLog`` Postgres
table for the admin UI -- a different concern from stdlib ``logging`` used
for developer-facing DEBUG/INFO/WARNING/ERROR output. Both can run side by
side; nothing here touches ``logger.py``.

Convention used across pipeline/*.py:
    DEBUG    per-frame detail (decode timing, motion ratios, track updates)
    INFO     stage summaries (video opened, model loaded, video finished)
    WARNING  a threshold/gate caused something to be skipped or a fallback
             engaged (e.g. TensorRT engine missing -> PyTorch fallback)
    ERROR    a frame/video/track failed outright
"""

from __future__ import annotations

import logging
import sys

_CONFIGURED = False


def configure_logging(level: str = "INFO") -> None:
    global _CONFIGURED
    root = logging.getLogger("epic.pipeline")
    root.setLevel(getattr(logging, level.upper(), logging.INFO))

    if not _CONFIGURED:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(
            logging.Formatter(
                fmt="%(asctime)s.%(msecs)03d %(levelname)-7s %(name)s: %(message)s",
                datefmt="%Y-%m-%d %H:%M:%S",
            )
        )
        root.addHandler(handler)
        root.propagate = False
        _CONFIGURED = True
    else:
        for existing_handler in root.handlers:
            existing_handler.setLevel(root.level)


def get_logger(name: str) -> logging.Logger:
    """Returns a child of the epic.pipeline logger, e.g. get_logger('decoder')."""
    if not _CONFIGURED:
        configure_logging()
    return logging.getLogger(f"epic.pipeline.{name}")
