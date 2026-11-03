"""
Per-track bookkeeping around Ultralytics' built-in ByteTrack.

ByteTrack itself lives inside the YOLO model instance (see
pipeline/detector.py) -- there is no standalone tracker object in this
codebase. What used to be three loose dictionaries maintained by hand in
integrated_pipeline.py's main loop (active_track_bboxes, active_track_last_seen,
track_cache) is collected here into one TrackState, with the stale-track
cleanup logic -- previously duplicated verbatim at three call sites --
implemented once each as ``cleanup_gated`` and ``cleanup_post_detection``.

IMPORTANT preserved quirk: those two cleanup methods are NOT symmetric, and
that asymmetry is intentional -- it matches pre-refactor behavior exactly:

  - cleanup_gated (called when a frame is motion-skipped) only trims
    active_bboxes, so a stale box stops being drawn on the HUD. It does NOT
    prune last_seen or cache -- those keep accumulating until a real
    detection frame runs cleanup_post_detection.
  - cleanup_post_detection (called after YOLO actually runs) prunes
    active_bboxes, last_seen, cache, AND the caller's logged_events map.

This means last_seen/cache can grow unbounded during a long run of gated
frames before the next real detection prunes them -- that was already true
of the original code and is not something this refactor changes.

track_cache entries are kept as plain dicts (not a dataclass) because
save_checkpoint/load_checkpoint and draw_hud already read/write them by key
name; wrapping them would mean touching those two call sites for no
behavioral gain.
"""

from __future__ import annotations

from typing import Any, Optional

TrackCacheEntry = dict[str, Any]


class TrackState:
    def __init__(self) -> None:
        self.active_bboxes: dict[int, list[int]] = {}
        self.last_seen: dict[int, int] = {}
        self.cache: dict[int, TrackCacheEntry] = {}

    def register_detection(self, track_id: int, bbox: tuple[int, int, int, int], frame_idx: int) -> None:
        self.last_seen[track_id] = frame_idx
        self.active_bboxes[track_id] = list(bbox)

    def get_or_create_cache_entry(self, track_id: int, frame_idx: int, timestamp: str) -> TrackCacheEntry:
        if track_id not in self.cache:
            self.cache[track_id] = {
                "status": "pending",
                "emp_id": None,
                "emp_name": f"Person #{track_id}",
                "conf": 0.0,
                "attempts": 0,
                "face_samples": [],
                "locked": False,
                "first_frame": frame_idx,
                "first_timestamp": timestamp,
            }
        return self.cache[track_id]

    def cleanup_gated(self, frame_idx: int, max_age: int) -> list[int]:
        """Trims only active_bboxes -- see module docstring for why."""
        stale_ids = [tid for tid, last_f in self.last_seen.items() if (frame_idx - last_f) > max_age]
        for tid in stale_ids:
            self.active_bboxes.pop(tid, None)
        return stale_ids

    def cleanup_post_detection(self, frame_idx: int, max_age: int, logged_events: Optional[dict] = None) -> list[int]:
        """Prunes active_bboxes, last_seen, cache, and logged_events."""
        lost_ids = [tid for tid, last_f in self.last_seen.items() if (frame_idx - last_f) > max_age]
        for tid in lost_ids:
            self.active_bboxes.pop(tid, None)
            self.last_seen.pop(tid, None)
            self.cache.pop(tid, None)
            if logged_events is not None:
                logged_events.pop(tid, None)
        return lost_ids
