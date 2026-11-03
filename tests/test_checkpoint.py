"""
EPIC Checkpoint Serialization Verification
==========================================
Tests the save_checkpoint and load_checkpoint functions.
"""

import os
import sys
import unittest
import tempfile
import json

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from integrated_pipeline import save_checkpoint, load_checkpoint


class DummyEvent:
    def __init__(self, id_val):
        self.id = id_val


class TestCheckpoint(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.checkpoint_path = os.path.join(self.temp_dir.name, "test_video_checkpoint.json")

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_checkpoint_save_and_load(self):
        # 1. Prepare dummy data
        active_tracks = {1: [100, 100, 300, 300], 2: [400, 400, 500, 600]}
        track_cache = {
            1: {
                "status": "recognized",
                "emp_id": "EMP101",
                "emp_name": "Alice Smith",
                "conf": 0.88,
                "attempts": 4,
                "face_samples": [("dummy_q", "dummy_face")],
                "locked": True,
                "first_frame": 10,
                "first_timestamp": "04-08-2026 09:00:10"
            }
        }
        logged_events = {1: DummyEvent(45)}
        parts_list = ["test_video.mp4_part_0.mp4"]

        # 2. Save checkpoint
        save_checkpoint(
            checkpoint_path=self.checkpoint_path,
            frame_idx=1500,
            active_tracks=active_tracks,
            track_cache=track_cache,
            logged_events=logged_events,
            parts_list=parts_list
        )

        self.assertTrue(os.path.exists(self.checkpoint_path))

        # 3. Load checkpoint
        loaded_data = load_checkpoint(self.checkpoint_path)
        self.assertIsNotNone(loaded_data)
        self.assertEqual(loaded_data["last_frame_idx"], 1500)
        self.assertEqual(loaded_data["parts_list"], parts_list)

        # Confirm face_samples (raw objects) are excluded but other fields are restored
        cache = loaded_data["track_recognition_cache"]["1"]
        self.assertEqual(cache["status"], "recognized")
        self.assertEqual(cache["emp_id"], "EMP101")
        self.assertEqual(cache["face_samples_count"], 1)

        # Confirm active tracks are serialized
        self.assertEqual(loaded_data["active_tracks"]["1"], [100, 100, 300, 300])

        # Confirm event IDs are preserved
        self.assertEqual(loaded_data["logged_event_ids"]["1"], 45)


if __name__ == "__main__":
    unittest.main()
