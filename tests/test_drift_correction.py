"""
EPIC Timestamp Drift Correction Verification
=============================================
Tests the TimestampDriftCorrector logic.
"""

import os
import sys
import unittest
from datetime import datetime, timedelta
import numpy as np

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from integrated_pipeline import TimestampDriftCorrector, parse_video_start_time


class DummyEvent:
    def __init__(self, id_val, frame_number):
        self.id = id_val
        self.frame_number = frame_number
        self.timestamp = ""


class DummyQuery:
    def __init__(self, events):
        self.events = events

    def filter(self, *args, **kwargs):
        return self

    def all(self):
        return self.events


class DummyDB:
    def __init__(self, events):
        self.events = events
        self.committed = False
        self.rolled_back = False

    def query(self, model_class):
        return DummyQuery(self.events)

    def commit(self):
        self.committed = True

    def rollback(self):
        self.rolled_back = True


class TestDriftCorrection(unittest.TestCase):
    def test_online_timestamp_interpolation(self):
        start_time_str = "04-08-2026 12:00:00"
        start_dt = parse_video_start_time(start_time_str)
        
        # 1. Initialize corrector (25 FPS)
        corrector = TimestampDriftCorrector(fps=25.0, start_time_dt=start_dt)
        
        # At start (frame 0)
        self.assertEqual(corrector.get_online_timestamp(0), start_time_str)
        
        # Add sample at frame 1500 (1 minute in) with a 2-second drift (62 seconds later)
        drifted_time_str = "04-08-2026 12:01:02"
        corrector.add_sample(1500, drifted_time_str)
        
        # Get online timestamp at frame 750 (extrapolates from the latest sample before 750, which is frame 0)
        # Frame 0 is 12:00:00. 750 frames at 25fps is 30s. So 12:00:30.
        ts_half = corrector.get_online_timestamp(750)
        self.assertEqual(ts_half, "04-08-2026 12:00:30")

    def test_retrospective_database_correction(self):
        start_time_str = "04-08-2026 12:00:00"
        start_dt = parse_video_start_time(start_time_str)
        
        corrector = TimestampDriftCorrector(fps=25.0, start_time_dt=start_dt)
        
        # Add sample at frame 3000 (2 minutes in) showing 10 seconds of accumulated drift (130 seconds total)
        corrector.add_sample(3000, "04-08-2026 12:02:10")
        
        # Create dummy events to correct
        ev1 = DummyEvent(1, 0)
        ev2 = DummyEvent(2, 1500)
        ev3 = DummyEvent(3, 3000)
        
        db = DummyDB([ev1, ev2, ev3])
        
        # Correct events
        corrector.fit_and_correct_events(video_id=99, db=db)
        
        self.assertTrue(db.committed)
        
        # Check corrected event timestamps
        self.assertEqual(ev1.timestamp, "04-08-2026 12:00:00")
        self.assertEqual(ev2.timestamp, "04-08-2026 12:01:05") # 130s / 2 = 65s -> 12:01:05
        self.assertEqual(ev3.timestamp, "04-08-2026 12:02:10")


if __name__ == "__main__":
    unittest.main()
