import os
import cv2
import time
import pickle
from datetime import datetime
from insightface.app import FaceAnalysis

import numpy as np

# Ensure insightface uses CUDA if available, fallback to CPU if cuDNN is missing
def init_insightface():
    try:
        print("[InsightFace] Testing CUDAExecutionProvider...")
        app = FaceAnalysis(providers=['CUDAExecutionProvider', 'CPUExecutionProvider'])
        app.prepare(ctx_id=0, det_size=(640, 640))
        # Warmup test run to verify cuDNN DLLs are loaded properly
        dummy = np.zeros((128, 128, 3), dtype=np.uint8)
        app.get(dummy)
        print("[InsightFace] GPU (CUDA) initialized successfully!")
        return app
    except Exception as e:
        print(f"[InsightFace] CUDA/cuDNN unavailable ({e}). Falling back to CPUExecutionProvider...")
        app = FaceAnalysis(providers=['CPUExecutionProvider'])
        app.prepare(ctx_id=0, det_size=(640, 640))
        print("[InsightFace] CPU initialized successfully!")
        return app

# Lazily loaded insightface app
_face_app = None

def get_face_app():
    global _face_app
    if _face_app is None:
        _face_app = init_insightface()
    return _face_app

def get_face_quality(frame, face):
    """Simple heuristic for face quality based on size and detection score"""
    score = face.det_score
    if score < 0.5:
        return 0.0
    w = face.bbox[2] - face.bbox[0]
    h = face.bbox[3] - face.bbox[1]
    return score * w * h

def get_encoding_weight(face) -> float:
    """
    Bounded per-encoding match weight derived from detection confidence, stored
    alongside each embedding so recognition-time matching (matcher.py /
    integrated_pipeline.py's search_with_margin) can favor better enrollment
    captures instead of treating every encoding as equally trustworthy
    (previously all encodings silently defaulted to weight 1.0 because nothing
    was ever persisted here). Deliberately narrow ([0.8, 1.0], monotonic in
    det_score) so it nudges matching rather than swinging accept/reject
    decisions -- a wider range would need labeled-data validation first.
    """
    score = float(getattr(face, "det_score", 0.5) or 0.5)
    return 0.8 + 0.2 * min(1.0, max(0.0, (score - 0.5) / 0.5))

def process_biometric_background(staff_id: str, name: str, video_path: str, pkl_path: str, dp_dir: str, photo_path: str = None):
    """
    Background worker to extract faces from video and/or photo, and save to PKL.
    """
    app = get_face_app()
    encoding_vectors = []
    encoding_weights = []

    dp_filename = f"{staff_id}_dp.jpg"

    # Process photo if provided (to get at least one base encoding)
    if photo_path and os.path.exists(photo_path):
        print(f"Processing photo for {name} ({staff_id}) from {photo_path}")
        frame = cv2.imread(photo_path)
        if frame is not None:
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            try:
                faces = app.get(rgb_frame)
                if not faces:
                    resized = cv2.resize(rgb_frame, (640, 640))
                    faces = app.get(resized)
                if faces:
                    face = sorted(faces, key=lambda x: (x.bbox[2]-x.bbox[0]) * (x.bbox[3]-x.bbox[1]), reverse=True)[0]
                    encoding_vectors.append(face.embedding.tolist())
                    encoding_weights.append(get_encoding_weight(face))
            except Exception as e:
                print(f"Error processing photo: {e}")

    # Process video if provided
    if video_path and os.path.exists(video_path):
        print(f"Starting video processing for {name} ({staff_id}) from {video_path}")
        cap = cv2.VideoCapture(video_path)
        if cap.isOpened():
            video_fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
            frame_interval = max(1, int(video_fps / 10)) # Extract ~10 FPS

            extracted_count = 0
            frame_count = 0
            start_time = time.time()
            MAX_SEC_TO_PROCESS = 120
            MAX_ENCODINGS = 500
            
            while True:
                ret, frame = cap.read()
                if not ret:
                    break
                    
                if time.time() - start_time > MAX_SEC_TO_PROCESS or extracted_count >= MAX_ENCODINGS:
                    break
                    
                if frame_count % frame_interval == 0:
                    try:
                        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                        faces = app.get(rgb_frame)
                        
                        if faces:
                            # Get largest face
                            face = sorted(faces, key=lambda x: (x.bbox[2]-x.bbox[0]) * (x.bbox[3]-x.bbox[1]), reverse=True)[0]
                            quality = get_face_quality(frame, face)

                            if quality > 0.0:
                                encoding_vectors.append(face.embedding.tolist())
                                encoding_weights.append(get_encoding_weight(face))
                                extracted_count += 1
                    except Exception as e:
                        print(f"Error processing frame: {e}")
                        
                frame_count += 1
            cap.release()
            
        # Preserve registration video for dashboard verification playback
        pass
    
    if len(encoding_vectors) > 0:
        # Load existing encodings
        if os.path.exists(pkl_path):
            with open(pkl_path, 'rb') as f:
                data = pickle.load(f)
        else:
            data = {}
            
        # Update encodings
        data[str(staff_id)] = {
            'name': name,
            'encodings': encoding_vectors,
            'weights': encoding_weights,
            'registered_at': datetime.now().isoformat(),
            'dp_path': f"/static/profiles/{dp_filename}"
        }
        
        # Save encodings
        with open(pkl_path, 'wb') as f:
            pickle.dump(data, f)
            
        print(f"Successfully registered {name} ({staff_id}) with {len(encoding_vectors)} encodings.")
        
        # We need to update the database to set has_face_encoding = True
        from database.database import SessionLocal, Staff
        db = SessionLocal()
        try:
            staff_record = db.query(Staff).filter(Staff.staff_id == str(staff_id)).first()
            if staff_record:
                staff_record.has_face_encoding = True
                if hasattr(staff_record, "is_active"):
                    staff_record.is_active = True
                db.commit()
                print(f"Updated database for {staff_id}: has_face_encoding=True, is_active=True")
        except Exception as e:
            print(f"DB Error updating staff: {e}")
            db.rollback()
        finally:
            db.close()
    else:
        print(f"No faces found for {staff_id}. Could not register encodings.")
