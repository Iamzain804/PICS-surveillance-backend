"""
EPIC Ambiguous Review Queue & Active Learning Verification
===========================================================
Tests the GET /api/review/pending and POST /api/review/resolve endpoints.
"""

import os
import sys
import unittest
import tempfile
import json
import pickle
import numpy as np

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from api_server import app
from database.database import SessionLocal, Staff, Event, ReviewQueue, Branch, Video


class TestReviewQueueAPI(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        self.db = SessionLocal()

        # Create defaults idempotently
        self.branch = self.db.query(Branch).filter(Branch.name == "Test Branch").first()
        if not self.branch:
            self.branch = Branch(name="Test Branch")
            self.db.add(self.branch)
            self.db.commit()
            self.db.refresh(self.branch)

        self.staff1 = self.db.query(Staff).filter(Staff.staff_id == "EMP9001").first()
        if not self.staff1:
            self.staff1 = Staff(
                staff_id="EMP9001",
                name="Bob Jones",
                email="bob@jones.local",
                branch_id=self.branch.id,
                has_face_encoding=False
            )
            self.db.add(self.staff1)

        self.staff2 = self.db.query(Staff).filter(Staff.staff_id == "EMP9002").first()
        if not self.staff2:
            self.staff2 = Staff(
                staff_id="EMP9002",
                name="Charlie Brown",
                email="charlie@brown.local",
                branch_id=self.branch.id,
                has_face_encoding=False
            )
            self.db.add(self.staff2)

        # Create test Video to avoid not-null constraint failure
        self.video = Video(
            filename="test_video_review.mp4",
            folder_type="checkin",
            file_size_mb=1.2,
            duration_seconds=60.0,
            resolution="640x480",
            fps=25.0,
            status="completed"
        )
        self.db.add(self.video)
        self.db.commit()
        self.db.refresh(self.video)

        self.event = Event(
            video_id=self.video.id,
            camera_role="checkin",
            track_id=12,
            timestamp="04-08-2026 12:00:00",
            frame_number=100,
            recognition_status="ambiguous",
            employee_name="EMP9001"
        )
        self.db.add(self.event)
        self.db.commit()

        self.temp_crop = tempfile.NamedTemporaryFile(suffix=".jpg", delete=False)
        self.temp_crop.write(b"dummy image bytes")
        self.temp_crop.close()

        self.review = ReviewQueue(
            event_id=self.event.id,
            suggested_staff_id="EMP9001",
            confidence=0.48,
            status="pending",
            face_crop_path=self.temp_crop.name
        )
        self.db.add(self.review)
        self.db.commit()

    def tearDown(self):
        self.db.query(ReviewQueue).filter(ReviewQueue.id == self.review.id).delete()
        self.db.query(Event).filter(Event.id == self.event.id).delete()
        self.db.query(Video).filter(Video.id == self.video.id).delete()
        self.db.query(Staff).filter(Staff.staff_id.in_(["EMP9001", "EMP9002"])).delete()
        self.db.query(Branch).filter(Branch.id == self.branch.id).delete()
        self.db.commit()
        self.db.close()
        if os.path.exists(self.temp_crop.name):
            os.remove(self.temp_crop.name)

    def test_get_pending_reviews(self):
        response = self.client.get("/api/review/pending")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertTrue(len(data) >= 1)
        
        # Verify columns match
        item = [x for x in data if x["id"] == self.review.id][0]
        self.assertEqual(item["suggested_staff_id"], "EMP9001")
        self.assertEqual(item["confidence"], 0.48)
        self.assertEqual(item["status"], "pending")
        self.assertIsNotNone(item["event"])
        self.assertEqual(item["event"]["track_id"], 12)

    def test_resolve_accept_suggested(self):
        payload = {
            "review_id": self.review.id,
            "action": "accept_suggested"
        }
        response = self.client.post("/api/review/resolve", json=payload)
        self.assertEqual(response.status_code, 200)
        
        # Refresh and verify
        self.db.refresh(self.event)
        self.db.refresh(self.review)
        self.assertEqual(self.event.recognition_status, "recognized")
        self.assertEqual(self.event.employee_id, "EMP9001")
        self.assertEqual(self.event.employee_name, "Bob Jones")
        self.assertEqual(self.review.status, "resolved")

    def test_resolve_assign_staff_id(self):
        payload = {
            "review_id": self.review.id,
            "action": "assign_staff_id",
            "assign_staff_id": "EMP9002"
        }
        response = self.client.post("/api/review/resolve", json=payload)
        self.assertEqual(response.status_code, 200)
        
        # Refresh and verify
        self.db.refresh(self.event)
        self.db.refresh(self.review)
        self.assertEqual(self.event.recognition_status, "recognized")
        self.assertEqual(self.event.employee_id, "EMP9002")
        self.assertEqual(self.event.employee_name, "Charlie Brown")
        self.assertEqual(self.review.status, "resolved")

    def test_resolve_mark_unrecognized(self):
        payload = {
            "review_id": self.review.id,
            "action": "mark_unrecognized"
        }
        response = self.client.post("/api/review/resolve", json=payload)
        self.assertEqual(response.status_code, 200)
        
        # Refresh and verify
        self.db.refresh(self.event)
        self.db.refresh(self.review)
        self.assertEqual(self.event.recognition_status, "unrecognized")
        self.assertIsNone(self.event.employee_id)
        self.assertEqual(self.review.status, "resolved")


if __name__ == "__main__":
    unittest.main()
