import cv2
import numpy as np
import insightface
from insightface.app import FaceAnalysis
import pickle
import os

def main():
    print("=== TESTING OPTIMAL THRESHOLD (0.44) & DET_SIZE (640x640) ON ATTENDANCE VIDEO ===\n")

    video_path = r"D:\EEpic\web-admin-backend\data\raw\attendance\200.0.0.25_ch5_20260810100001_20260810220000.mp4"
    pkl_path = r"D:\EEpic\web-admin-backend\ai\encoding\encodings.pkl"

    with open(pkl_path, "rb") as f:
        known_db = pickle.load(f)

    # Query Staff DB for name mapping
    import psycopg2
    conn = psycopg2.connect(dbname='testdb1', user='postgres', password='1234', host='localhost', port=5432)
    cur = conn.cursor()
    cur.execute("SELECT staff_id, name FROM staff")
    staff_name_map = {r[0]: r[1] for r in cur.fetchall()}
    cur.close()
    conn.close()

    embeddings_list = []
    known_names = []
    known_ids = []

    for sid, items in known_db.items():
        sname = staff_name_map.get(sid, sid)
        for item in items:
            emb = item.get("encoding") if isinstance(item, dict) else item
            if emb is not None:
                norm = np.linalg.norm(emb)
                if norm > 0:
                    embeddings_list.append(emb / norm)
                    known_names.append(sname)
                    known_ids.append(sid)

    known_matrix = np.array(embeddings_list, dtype=np.float32)

    app = FaceAnalysis(name='buffalo_l', providers=['CPUExecutionProvider'])
    app.prepare(ctx_id=0, det_size=(640, 640), det_thresh=0.15)

    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)

    # Test 30 sample frames across the 12-hour video
    frame_indices = [int(fps * sec) for sec in range(120, 3600, 120)] # Every 2 minutes in the first hour

    recognized_count_44 = 0
    recognized_count_52 = 0
    total_faces_found = 0

    print(f"{'Frame':<8} | {'Video Time':<10} | {'Face Size':<10} | {'Matched Staff':<30} | {'Score':<8} | {'Status (0.44)':<15} | {'Status (0.52)'}")
    print("-" * 110)

    for f_idx in frame_indices:
        cap.set(cv2.CAP_PROP_POS_FRAMES, f_idx)
        ret, frame = cap.read()
        if not ret: continue

        time_sec = f_idx / fps
        time_str = f"{int(time_sec // 3600):02d}:{int((time_sec % 3600) // 60):02d}:{int(time_sec % 60):02d}"

        faces = app.get(frame)
        total_faces_found += len(faces)

        for f_obj in faces:
            emb = f_obj.embedding.astype(np.float32)
            norm = np.linalg.norm(emb)
            if norm > 0: emb = emb / norm

            sims = np.dot(known_matrix, emb)
            max_i = int(np.argmax(sims))
            score = float(sims[max_i])
            matched_name = known_names[max_i]

            st_44 = "RECOGNIZED" if score >= 0.44 else "Unrecognized"
            st_52 = "RECOGNIZED" if score >= 0.52 else "Unrecognized"

            if score >= 0.44: recognized_count_44 += 1
            if score >= 0.52: recognized_count_52 += 1

            f_size = f"{int(f_obj.bbox[2]-f_obj.bbox[0])}x{int(f_obj.bbox[3]-f_obj.bbox[1])}"
            print(f"{f_idx:<8} | {time_str:<10} | {f_size:<10} | {matched_name:<30} | {score:.4f}  | {st_44:<15} | {st_52}")

    cap.release()

    print("-" * 110)
    print(f"Total Faces Evaluated: {total_faces_found}")
    print(f"Recognized with 0.44 Threshold: {recognized_count_44} faces")
    print(f"Recognized with 0.52 Threshold: {recognized_count_52} faces")

if __name__ == "__main__":
    main()
