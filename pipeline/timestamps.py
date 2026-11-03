"""
Real-world timestamp handling: parsing OCR'd video-start strings, per-frame
timestamp calculation, and retrospective linear-interpolation drift
correction against burnt-in OCR timestamps sampled periodically through a
video. Moved from integrated_pipeline.py verbatim.
"""

from __future__ import annotations

from datetime import datetime, timedelta
from typing import Any, Optional

from pipeline.logging_setup import get_logger

logger = get_logger("timestamps")


def parse_video_start_time(video_start_time_str: Optional[str]) -> Optional[datetime]:
    """Parses a video start time string to a datetime object."""
    if not video_start_time_str:
        return None
    for fmt in ["%d-%m-%Y %H:%M:%S", "%Y-%m-%d %H:%M:%S", "%d/%m/%Y %H:%M:%S", "%d-%m-%Y %H.%M.%S"]:
        try:
            return datetime.strptime(video_start_time_str.strip(), fmt)
        except ValueError:
            continue
    return None


def calculate_real_timestamp(start_dt: Optional[datetime], frame_idx: int, fps: float) -> str:
    """Calculates a formatted real-world timestamp for a specific frame."""
    fps_valid = max(fps, 1.0)
    if start_dt:
        curr_dt = start_dt + timedelta(seconds=(frame_idx / fps_valid))
        return curr_dt.strftime("%d-%m-%Y %H:%M:%S")
    total_sec = int(frame_idx / fps_valid)
    hrs = total_sec // 3600
    mins = (total_sec % 3600) // 60
    secs = total_sec % 60
    return f"{hrs:02d}:{mins:02d}:{secs:02d}"


class TimestampDriftCorrector:
    """
    Tracks periodic OCR timestamps to check and correct frame-wise timestamps
    using linear interpolation to solve video timeline drift.
    """

    def __init__(self, fps: float, start_time_dt: Optional[datetime] = None) -> None:
        self.fps = fps
        self.start_time_dt = start_time_dt
        self.samples: list[tuple[int, datetime]] = []
        if start_time_dt:
            self.samples.append((0, start_time_dt))

    def add_sample(self, frame_idx: int, ocr_time_str: str) -> None:
        dt = parse_video_start_time(ocr_time_str)
        if dt:
            self.samples = [s for s in self.samples if s[0] != frame_idx]
            self.samples.append((frame_idx, dt))
            self.samples.sort(key=lambda x: x[0])
            logger.debug("Added OCR sample at frame %d: %s", frame_idx, ocr_time_str)

    def get_online_timestamp(self, frame_idx: int) -> str:
        """Extrapolates/interpolates real-time timestamp using the latest available OCR sample."""
        if not self.samples:
            if self.start_time_dt:
                curr_dt = self.start_time_dt + timedelta(seconds=(frame_idx / self.fps))
                return curr_dt.strftime("%d-%m-%Y %H:%M:%S")
            return "00:00:00"

        latest_sample = self.samples[-1]
        for f_idx, dt in reversed(self.samples):
            if f_idx <= frame_idx:
                latest_sample = (f_idx, dt)
                break

        f_idx, dt = latest_sample
        diff_sec = (frame_idx - f_idx) / self.fps
        target_dt = dt + timedelta(seconds=diff_sec)
        return target_dt.strftime("%d-%m-%Y %H:%M:%S")

    def fit_and_correct_events(self, video_id: Optional[int], db: Any) -> None:
        """Fits corrected_time = f(frame_idx) and updates all events in the database."""
        if video_id is None:
            return
        if len(self.samples) < 2:
            logger.info("Insufficient OCR samples for drift interpolation -- skipping correction.")
            return

        from scipy.interpolate import interp1d

        from database.database import Event

        logger.info("Fitting linear interpolation on %d time anchor points...", len(self.samples))
        self.samples.sort(key=lambda x: x[0])

        import numpy as np

        x = np.array([float(s[0]) for s in self.samples])
        y = np.array([float(s[1].timestamp()) for s in self.samples])

        try:
            interp_func = interp1d(x, y, kind="linear", fill_value="extrapolate")

            events = db.query(Event).filter(Event.video_id == video_id).all()
            if not events:
                return

            logger.info("Retrospectively correcting timestamps for %d events...", len(events))
            corrected_count = 0
            for ev in events:
                if ev.frame_number is not None:
                    corrected_epoch = float(interp_func(float(ev.frame_number)))
                    corrected_dt = datetime.fromtimestamp(corrected_epoch)
                    ev.timestamp = corrected_dt.strftime("%d-%m-%Y %H:%M:%S")
                    corrected_count += 1

            db.commit()
            logger.info("Corrected %d database event timestamps.", corrected_count)
        except Exception as e:
            db.rollback()
            logger.warning("Failed to fit or apply drift interpolation: %s", e)
