"""
JSON checkpoint save/restore for long-running single-pass video processing.

Moved from integrated_pipeline.py verbatim (same JSON shape), so existing
checkpoint files on disk from before this refactor remain loadable.
"""

from __future__ import annotations

import json
import os
from typing import Any, Optional

from pipeline.logging_setup import get_logger

logger = get_logger("checkpoint")


def save_checkpoint(
    checkpoint_path: str,
    frame_idx: int,
    active_tracks: dict[int, list[int]],
    track_cache: dict[int, dict[str, Any]],
    logged_events: dict[int, Any],
    parts_list: list[str],
) -> None:
    """Serialises current pipeline tracking and identity status to a JSON checkpoint file."""
    serializable_cache = {
        str(tid): {
            "status": info.get("status"),
            "emp_id": info.get("emp_id"),
            "emp_name": info.get("emp_name"),
            "conf": info.get("conf"),
            "attempts": info.get("attempts"),
            "locked": info.get("locked"),
            "first_frame": info.get("first_frame"),
            "first_timestamp": info.get("first_timestamp"),
            "face_samples_count": len(info.get("face_samples", [])),
        }
        for tid, info in track_cache.items()
    }

    serializable_tracks = {str(tid): bbox for tid, bbox in active_tracks.items()}
    logged_event_ids = {
        str(tid): int(evt.id)
        for tid, evt in logged_events.items()
        if hasattr(evt, "id") and evt.id is not None
    }

    data = {
        "last_frame_idx": frame_idx,
        "active_tracks": serializable_tracks,
        "track_recognition_cache": serializable_cache,
        "logged_event_ids": logged_event_ids,
        "parts_list": parts_list,
    }

    try:
        with open(checkpoint_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=4)
        logger.info("Saved checkpoint at frame %d to: %s", frame_idx, checkpoint_path)
    except Exception as e:
        logger.warning("Failed to save checkpoint: %s", e)


def load_checkpoint(checkpoint_path: str) -> Optional[dict[str, Any]]:
    """Loads an existing pipeline checkpoint if present."""
    if not os.path.exists(checkpoint_path):
        return None
    try:
        with open(checkpoint_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        logger.info("Found existing checkpoint. Resuming from frame %s", data.get("last_frame_idx"))
        return data
    except Exception as e:
        logger.warning("Failed to load checkpoint: %s", e)
        return None
