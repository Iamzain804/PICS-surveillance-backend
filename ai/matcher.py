import os
import pickle
import numpy as np
import cv2
import insightface
from insightface.app import FaceAnalysis
from typing import Tuple, Optional, Dict, Any, List

class FaceMatcher:
    def __init__(self, pkl_path: Optional[str] = None, similarity_threshold: float = 0.44):
        if pkl_path is None:
            default_path = os.path.join(os.path.dirname(__file__), "encoding", "encodings.pkl")
            fallback_path = os.path.join(os.path.dirname(__file__), "encodings.pkl")
            pkl_path = default_path if os.path.exists(default_path) else fallback_path
        self.pkl_path = pkl_path
        self.similarity_threshold = similarity_threshold
        self.known_db = {}
        
        # Pre-compiled Matrix for 1-ms Vectorized Matrix Multiplication
        self.known_matrix: Optional[np.ndarray] = None
        self.known_names: List[str] = []
        self.known_ids: List[str] = []
        self.known_weights: List[float] = []
        
        self.face_app = None
        self._load_database()
        self._init_insightface()

    def _load_database(self):
        if not os.path.exists(self.pkl_path):
            print(f"[WARNING] PKL file not found at {self.pkl_path}")
            return
        
        with open(self.pkl_path, "rb") as f:
            self.known_db = pickle.load(f)
        
        # Build Vectorized Matrix: Shape (Total_Embeddings, 512)
        embeddings_list = []
        names_list = []
        ids_list = []
        weights_list = []

        # Query Staff DB for full names lookup
        staff_name_map = {}
        try:
            from database.database import SessionLocal, Staff
            db_s = SessionLocal()
            for st in db_s.query(Staff).all():
                if st.staff_id:
                    staff_name_map[str(st.staff_id).strip()] = st.name
            db_s.close()
        except Exception:
            pass

        for person_id, data in self.known_db.items():
            pid_str = str(person_id).strip()
            real_name = staff_name_map.get(pid_str)
            if real_name:
                display_name = f"{real_name} (ID: {pid_str})"
            else:
                display_name = pid_str

            if isinstance(data, list):
                enc_list = data
                name = display_name
                weights = [1.0] * len(enc_list)
            elif isinstance(data, dict):
                name = data.get("name", display_name)
                enc_list = data.get("encodings", [])
                weights = data.get("weights", [])
            else:
                continue

            for i, emb in enumerate(enc_list):
                emb_arr = np.array(emb, dtype=np.float32)
                norm = np.linalg.norm(emb_arr)
                if norm > 0:
                    emb_arr = emb_arr / norm  # L2 Normalize
                embeddings_list.append(emb_arr)
                names_list.append(name)
                ids_list.append(str(person_id))
                
                # Default weight to 1.0 if not specified
                w = weights[i] if i < len(weights) else 1.0
                weights_list.append(w)

        if embeddings_list:
            self.known_matrix = np.vstack(embeddings_list)  # (N, 512)
            self.known_names = names_list
            self.known_ids = ids_list
            self.known_weights = weights_list
            print(f"[SUCCESS] Vectorized PKL Matrix created: {self.known_matrix.shape} embeddings for {len(set(ids_list))} persons.")

    def _init_insightface(self):
        # Initialize InsightFace with CUDA GPU
        self.face_app = FaceAnalysis(name='buffalo_l', providers=['CUDAExecutionProvider', 'CPUExecutionProvider'])
        # Detection size (640, 640) for high-precision face landmark detection on distance CCTV crops
        self.face_app.prepare(ctx_id=0, det_size=(640, 640), det_thresh=0.15)

    def recognize_crop(self, crop_bgr: np.ndarray) -> Tuple[bool, str, Optional[str], float]:
        """
        Ultra-fast vectorized face recognition on cropped head/body image.
        """
        if crop_bgr is None or crop_bgr.size == 0 or self.face_app is None or self.known_matrix is None:
            return False, "Unauthorized", None, 0.0

        # Crop top 55% (Head/Face region) if crop is full body to speed up face detection
        h, w, _ = crop_bgr.shape
        if h > 100:
            head_crop = crop_bgr[0:int(h * 0.55), 0:w]
        else:
            head_crop = crop_bgr

        faces = self.face_app.get(head_crop)
        if not faces:
            # Fallback to full crop if no face found in top 45%
            faces = self.face_app.get(crop_bgr)
            if not faces:
                return False, "Unauthorized", None, 0.0

        # Pick largest face
        faces = sorted(faces, key=lambda x: (x.bbox[2]-x.bbox[0])*(x.bbox[3]-x.bbox[1]), reverse=True)
        face_emb = faces[0].embedding.astype(np.float32)
        norm = np.linalg.norm(face_emb)
        if norm > 0:
            face_emb = face_emb / norm

        # ⚡ 1-Millisecond Matrix Dot Product for all 6,000+ encodings ⚡
        similarities = np.dot(self.known_matrix, face_emb)
        # Apply quality weights
        weighted_similarities = similarities * np.array(self.known_weights, dtype=np.float32)
        max_idx = int(np.argmax(weighted_similarities))
        best_score = float(weighted_similarities[max_idx])

        if best_score >= self.similarity_threshold:
            best_person_name = self.known_names[max_idx]
            best_person_id = self.known_ids[max_idx]
            return True, best_person_name, best_person_id, round(best_score, 4)
        else:
            return False, "Unauthorized", None, round(best_score, 4)
