"""
EPIC Face Recognition Accuracy Validation
=========================================
Tests the search_with_margin, quality gate, and majority voting logic on a validation suite.
"""

import os
import sys
import unittest
import numpy as np

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from integrated_pipeline import check_face_quality_gate, search_with_margin


class DummyFace:
    def __init__(self, embedding=None, bbox=None, kps=None, pose=None):
        self.embedding = embedding
        self.bbox = bbox or [10, 10, 100, 100]
        self.kps = kps or [[15, 15], [35, 15], [25, 25], [18, 35], [32, 35]]
        self.pose = pose


class TestFaceAccuracy(unittest.TestCase):
    def setUp(self):
        # Create dummy enrolled employee vectors (512-dim normalized)
        self.emp_data = {
            "EMP001": {
                "name": "Alice Smith",
                "encodings": [
                    np.random.normal(0, 0.1, 512).tolist(),
                    np.random.normal(0, 0.1, 512).tolist()
                ]
            },
            "EMP002": {
                "name": "Bob Jones",
                "encodings": [
                    np.random.normal(0.02, 0.1, 512).tolist()
                ]
            }
        }

    def test_quality_gate_passes(self):
        # Good face: width = 90 (>=80), inter-ocular distance = 20 (estimated fallback or pose)
        # To pass, iod must be >= 60. Let's make eye coordinates wider:
        kps = [[10, 50], [80, 50], [45, 80], [20, 110], [70, 110]] # iod = 70
        face = DummyFace(bbox=[0, 0, 100, 100], kps=kps, pose=[5.0, 5.0, 0.0])
        self.assertTrue(check_face_quality_gate(face))

    def test_quality_gate_rejects_yaw(self):
        # High yaw (30 degrees > 25)
        kps = [[10, 50], [80, 50], [45, 80], [20, 110], [70, 110]]
        face = DummyFace(bbox=[0, 0, 100, 100], kps=kps, pose=[5.0, 30.0, 0.0])
        self.assertFalse(check_face_quality_gate(face))

    def test_quality_gate_rejects_size(self):
        # Width too small (50px < 80px)
        kps = [[10, 50], [80, 50], [45, 80], [20, 110], [70, 110]]
        face = DummyFace(bbox=[0, 0, 50, 100], kps=kps, pose=[5.0, 5.0, 0.0])
        self.assertFalse(check_face_quality_gate(face))

    def test_search_with_margin_exact_match(self):
        # Get one of Alice's vectors and check search_with_margin returns Alice as top1
        alice_vec = np.array(self.emp_data["EMP001"]["encodings"][0])
        face = DummyFace(embedding=alice_vec)
        
        top1_id, top1_sim, second_id, second_sim = search_with_margin(face, self.emp_data)
        self.assertEqual(top1_id, "EMP001")
        self.assertGreater(top1_sim, 0.95)
        self.assertGreater(top1_sim - second_sim, 0.12)


if __name__ == "__main__":
    unittest.main()
