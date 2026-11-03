"""
EPIC Automated Video Ingestion & Multi-Camera Orchestrator Daemon
=================================================================
Watches raw camera folders (checkin, checkout, breakin, breakout),
registers new video recordings in the database, and dispatches every
pending video in one batch to a single parallel_runner.py subprocess.
parallel_runner.py then processes videos ONE AT A TIME, splitting each
into CHUNKS_PER_VIDEO chunks that run as simultaneous GPU worker
subprocesses -- so within one video, chunk-parallelism gives a speedup,
but multiple videos in the same batch are NOT processed simultaneously;
total time scales with the number of videos queued.
"""

import os
import sys
import time
import signal
import logging
import argparse
import subprocess
from datetime import datetime
from typing import List, Dict, Any, Optional

from log_streaming import tee_stream_to_file_and_console

BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)

import cv2
from sqlalchemy.exc import IntegrityError
from database.database import SessionLocal, Video, get_db
from ai.ocr_extractor import extract_video_metadata_from_frame, parse_filename_timestamp

try:
    from config.settings import cfg as _cfg
    _watcher_cfg = _cfg.get("watcher", {})
except ImportError:
    _watcher_cfg = {}

DEFAULT_POLL_INTERVAL = int(_watcher_cfg.get("poll_interval_seconds", os.getenv("POLL_INTERVAL", "30")))
CAMERA_ROLES = _watcher_cfg.get("camera_roles", ["attendance", "checkin", "checkout", "breakin", "breakout"])
SUPPORTED_EXTENSIONS = set(_watcher_cfg.get("supported_extensions", [".mp4", ".avi", ".mov", ".mkv"]))
LOG_FILE = os.path.join(BACKEND_DIR, _watcher_cfg.get("log_file", "auto_pipeline.log"))

# Chunks-per-video passed to parallel_runner.py. Matches parallel_runner.py's
# own --chunks default (3) -- NOT config.yaml's parallel.default_chunks (4),
# which is currently unread/unvalidated dead config. Raising this beyond 3
# means N concurrent worker subprocesses each loading a full YOLO+InsightFace
# stack onto the same GPU; only bump it after confirming VRAM headroom.
CHUNKS_PER_VIDEO = 3

# ── Logging ────────────────────────────────────────────────────────────────
logger = logging.getLogger("EPIC_AutoPipeline")
logger.setLevel(logging.INFO)
formatter = logging.Formatter("[%(asctime)s] [%(levelname)s] [%(name)s]: %(message)s",
                               datefmt="%Y-%m-%d %H:%M:%S")
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)
try:
    file_handler = logging.FileHandler(LOG_FILE, encoding="utf-8")
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
except Exception as e:
    logger.warning(f"Could not initialize file log handler: {e}")

RUNNING = True

def signal_handler(signum, frame):
    global RUNNING
    logger.info(f"Received shutdown signal ({signum}). Gracefully stopping...")
    RUNNING = False

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)


# ── Helpers ────────────────────────────────────────────────────────────────

def is_file_ready(filepath: str, check_interval: float = 1.0) -> bool:
    try:
        if not os.path.exists(filepath):
            return False
        size1 = os.path.getsize(filepath)
        time.sleep(check_interval)
        size2 = os.path.getsize(filepath)
        return size1 > 0 and size1 == size2
    except Exception:
        return False


def get_raw_and_processed_roots(custom_raw: Optional[str] = None,
                                 custom_processed: Optional[str] = None):
    if custom_raw:
        raw_root = os.path.abspath(custom_raw)
    else:
        candidates = [
            os.path.join(BACKEND_DIR, "data", "raw"),
            os.path.join(BACKEND_DIR, "raw"),
            os.path.join(BACKEND_DIR, "..", "data", "raw"),
        ]
        raw_root = next((c for c in candidates if os.path.exists(c)), candidates[0])

    if custom_processed:
        processed_root = os.path.abspath(custom_processed)
    else:
        processed_root = os.path.join(BACKEND_DIR, "data", "processed")

    for role in CAMERA_ROLES:
        os.makedirs(os.path.join(raw_root, role), exist_ok=True)
        os.makedirs(os.path.join(processed_root, role), exist_ok=True)

    return raw_root, processed_root


def inspect_video_metadata(filepath: str) -> Dict[str, Any]:
    meta = {"file_size_mb": 0.0, "duration_seconds": 0.0,
            "resolution": "Unknown", "fps": 25.0,
            "video_start_time": None, "camera_name": None}
    try:
        meta["file_size_mb"] = round(os.path.getsize(filepath) / (1024 * 1024), 2)
        cap = cv2.VideoCapture(filepath)
        if cap.isOpened():
            fps = cap.get(cv2.CAP_PROP_FPS) or 25.0
            frame_count = cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0
            w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH) or 0)
            h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT) or 0)
            meta["fps"] = round(fps, 2)
            meta["duration_seconds"] = round(frame_count / max(fps, 1.0), 2)
            meta["resolution"] = f"{w}x{h}" if w and h else "Unknown"
            ret, first_frame = cap.read()
            fname = os.path.basename(filepath)
            if ret and first_frame is not None:
                try:
                    dt_obj, dt_str, cam_name = extract_video_metadata_from_frame(first_frame, filename=fname)
                    meta["video_start_time"] = dt_str
                    meta["camera_name"] = cam_name
                except Exception:
                    pass
            if not meta["video_start_time"]:
                _, dt_str = parse_filename_timestamp(fname)
                if dt_str:
                    meta["video_start_time"] = dt_str
            cap.release()
    except Exception as e:
        logger.warning(f"Error inspecting video metadata for {filepath}: {e}")
    return meta


def register_video_in_db(db, filename: str, folder_type: str, filepath: str) -> Video:
    abs_path = os.path.abspath(filepath)
    video = db.query(Video).filter(Video.filename == filename).first()
    if video:
        updated = False
        if video.folder_type != folder_type:
            video.folder_type = folder_type
            updated = True
        if video.file_path != abs_path:
            video.file_path = abs_path
            updated = True
        if video.status == "error":
            video.status = "pending"
            updated = True
        if updated:
            try:
                db.commit()
                db.refresh(video)
                logger.info(f"Updated existing video record: [{folder_type}] {filename} (ID #{video.id})")
            except IntegrityError:
                db.rollback()
                video = db.query(Video).filter(Video.filename == filename).first()
        return video

    meta = inspect_video_metadata(filepath)
    video = Video(
        filename=filename,
        folder_type=folder_type,
        file_path=abs_path,
        file_size_mb=meta["file_size_mb"],
        duration_seconds=meta["duration_seconds"],
        resolution=meta["resolution"],
        fps=meta["fps"],
        video_start_time=meta["video_start_time"],
        camera_name=meta["camera_name"] or f"{folder_type.capitalize()} Camera",
        status="pending",
        created_at=datetime.utcnow()
    )
    db.add(video)
    try:
        db.commit()
        db.refresh(video)
        logger.info(f"Registered new video: [{folder_type}] {filename} (ID #{video.id})")
    except IntegrityError:
        db.rollback()
        video = db.query(Video).filter(Video.filename == filename).first()
        if video:
            logger.info(f"Duplicate video filename found, using existing record: {filename} (ID #{video.id})")
        else:
            raise
    return video


def reset_stuck_videos():
    try:
        db = SessionLocal()
        stuck = db.query(Video).filter(Video.status == "processing").update({"status": "pending"})
        db.commit()
        if stuck > 0:
            logger.info(f"[Auto-Recovery] Reset {stuck} stuck video(s) back to 'pending'.")
        db.close()
    except Exception as e:
        logger.warning(f"[Auto-Recovery] Could not reset stuck videos: {e}")

def log_onnx_runtime_providers():
    try:
        import onnxruntime as ort
        providers = ort.get_available_providers()
        logger.info(f"[ONNX] Available providers: {providers}")
    except ImportError:
        logger.warning("[ONNX] onnxruntime is not installed in the active environment.")
    except Exception as e:
        logger.warning(f"[ONNX] Failed to query providers: {e}")

# ── Core: scan all roles, fire ALL videos simultaneously ──────────────────

def scan_and_process_round(raw_root: str, processed_root: str,
                            retry_errors: bool = False) -> int:
    """
    100% Dynamic Multi-Camera Scanner:
    1. Queries all Camera records in DB to scan their configured recording_path.
    2. Auto-discovers ANY subfolders inside raw_root dynamically (zero hardcoding).
    3. Collects every pending video and launches them via parallel_runner.
    """
    from database.database import Camera
    db = SessionLocal()
    pending_videos: List[Dict[str, Any]] = []

    try:
        # 1. Collect all watch directories dynamically
        watch_targets = {}  # dir_path -> {"role": role_name, "cam_obj": cam_or_none}

        # A. From Database Cameras
        try:
            db_cameras = db.query(Camera).all()
            for cam in db_cameras:
                r_path = cam.recording_path
                if r_path and os.path.isdir(r_path):
                    norm_p = os.path.abspath(r_path)
                    role = cam.activity_name or cam.name or "attendance"
                    watch_targets[norm_p] = {"role": role, "camera": cam}
        except Exception as e:
            logger.warning(f"Could not load cameras from DB: {e}")

        # B. Auto-discover ANY subdirectories in raw_root
        if os.path.isdir(raw_root):
            for entry in os.scandir(raw_root):
                if entry.is_dir():
                    norm_p = os.path.abspath(entry.path)
                    if norm_p not in watch_targets:
                        watch_targets[norm_p] = {"role": entry.name, "camera": None}

        # C. Fallback standard roles in raw_root if folders exist
        for role in CAMERA_ROLES:
            for variant in [role, role.capitalize(), role.upper()]:
                candidate = os.path.join(raw_root, variant)
                if os.path.isdir(candidate):
                    norm_p = os.path.abspath(candidate)
                    if norm_p not in watch_targets:
                        watch_targets[norm_p] = {"role": role, "camera": None}
                    break

        # 2. Scan all discovered directories for video files
        for target_dir, target_meta in watch_targets.items():
            role = target_meta["role"]
            cam_obj = target_meta["camera"]

            try:
                dir_files = os.listdir(target_dir)
            except Exception as e:
                logger.warning(f"Could not list directory {target_dir}: {e}")
                continue

            for fname in dir_files:
                if not RUNNING:
                    break
                _, ext = os.path.splitext(fname)
                if ext.lower() not in SUPPORTED_EXTENSIONS:
                    continue
                full_path = os.path.join(target_dir, fname)
                if not os.path.isfile(full_path):
                    continue
                if not is_file_ready(full_path):
                    logger.debug(f"File {fname} still being written, skipping.")
                    continue

                video_record = register_video_in_db(db, fname, role, full_path)
                if cam_obj and cam_obj.name and not video_record.camera_name:
                    video_record.camera_name = cam_obj.name
                    db.commit()

                if video_record.status == "completed":
                    logger.debug(f"Skipping already completed: [{role}] {fname}")
                    continue
                if video_record.status == "processing":
                    logger.info(f"Already processing, skipping: [{role}] {fname}")
                    continue
                if video_record.status == "error" and not retry_errors:
                    logger.debug(f"Skipping errored video (use --retry-errors): [{role}] {fname}")
                    continue

                v_stime = video_record.video_start_time
                if not v_stime:
                    _, dt_str = parse_filename_timestamp(fname)
                    v_stime = dt_str
                    if v_stime:
                        video_record.video_start_time = v_stime
                        db.commit()
                if not v_stime:
                    v_stime = datetime.now().strftime("%d-%m-%Y %H:%M:%S")

                pending_videos.append({
                    "video_id": video_record.id,
                    "role": role,
                    "fname": fname,
                    "full_path": os.path.abspath(full_path),
                    "start_time": v_stime,
                })
    finally:
        db.close()

    if not pending_videos:
        return 0

    runner_script = os.path.join(BACKEND_DIR, "parallel_runner.py")
    python_exe = sys.executable

    logger.info("=" * 70)
    logger.info(f"[BATCH LAUNCH] Queuing {len(pending_videos)} video(s) for sequential parallel-chunk processing:")
    for v in pending_videos:
        logger.info(f"  -> [{v['role']}] {v['fname']}")
    logger.info("=" * 70)

    # Launch ONE parallel_runner process for all pending videos.
    # parallel_runner processes videos sequentially (1 video at a time,
    # CHUNKS_PER_VIDEO chunks in parallel per video) to keep concurrent GPU
    # worker subprocesses bounded and avoid VRAM thrashing.
    v_paths = [v["full_path"] for v in pending_videos]
    v_roles = [v["role"] for v in pending_videos]
    v_times = [v["start_time"] for v in pending_videos]

    cmd = [
        python_exe,
        runner_script,
        "--videos", *v_paths,
        "--folder-types", *v_roles,
        "--start-times", *v_times,
        "--chunks", str(CHUNKS_PER_VIDEO),
    ]

    log_path = os.path.join(BACKEND_DIR, "auto_pipeline_batch.log")
    env = os.environ.copy()
    env["PYTHONIOENCODING"] = "utf-8"
    env["PYTHONUNBUFFERED"] = "1"

    t_start = time.time()
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=BACKEND_DIR,
        env=env,
        text=True,
        encoding="utf-8",
        errors="replace",
        bufsize=1,
    )
    logger.info(f"[LAUNCHED BATCH] PID {proc.pid} -> {len(pending_videos)} video(s) | log: {log_path}")

    tee_stream_to_file_and_console(proc.stdout, log_path, prefix="[PIPELINE] ")

    exit_code = proc.wait()
    total_elapsed = time.time() - t_start

    if exit_code == 0:
        logger.info(f"[ALL DONE] All {len(pending_videos)} video(s) completed successfully in {total_elapsed/60:.1f} minutes total.")
        return len(pending_videos)
    else:
        logger.error(f"[BATCH FAILED] parallel_runner exited with code {exit_code} - check {log_path}")
        return 0

    return completed


def _mark_video_status(video_id: int, status: str):
    try:
        db = SessionLocal()
        v = db.query(Video).filter(Video.id == video_id).first()
        if v:
            v.status = status
            db.commit()
        db.close()
    except Exception as e:
        logger.warning(f"Could not update video {video_id} status to {status}: {e}")


def _generate_excel_report():
    report_script = os.path.join(BACKEND_DIR, "generate_excel_report.py")
    try:
        logger.info("[REPORT] Generating Excel attendance report...")
        subprocess.run([sys.executable, report_script],
                       cwd=BACKEND_DIR, timeout=120)
        logger.info("[REPORT] Excel report generated successfully.")
    except Exception as e:
        logger.warning(f"[REPORT] Excel generation failed: {e}")


# ── Daemon loop ────────────────────────────────────────────────────────────

def run_daemon(interval: int = DEFAULT_POLL_INTERVAL,
               once: bool = False,
               raw_dir: Optional[str] = None,
               processed_dir: Optional[str] = None,
               retry_errors: bool = False):

    raw_root, processed_root = get_raw_and_processed_roots(raw_dir, processed_dir)

    logger.info("=" * 70)
    logger.info(" EPIC AUTOMATED VIDEO INGESTION & MULTI-CAMERA ORCHESTRATOR")
    logger.info("=" * 70)
    logger.info(f"  Raw Directory:      {raw_root}")
    logger.info(f"  Processed Dir:      {processed_root}")
    logger.info(f"  Camera Roles:       {', '.join(CAMERA_ROLES)}")
    logger.info(f"  Poll Interval:      {interval}s")
    logger.info(f"  Strategy:           videos processed ONE AT A TIME, chunks within a video run in parallel")
    logger.info(f"  Chunks per video:   {CHUNKS_PER_VIDEO} parallel GPU chunks")
    logger.info(f"  Expected time:      ~15-20 min per 12h video (scales with number of videos queued)")
    logger.info("=" * 70)

    log_onnx_runtime_providers()
    reset_stuck_videos()

    iteration = 0
    while RUNNING:
        iteration += 1
        logger.info(f"[Cycle #{iteration}] Scanning camera directories...")
        try:
            n = scan_and_process_round(raw_root, processed_root,
                                       retry_errors=retry_errors)
            if n > 0:
                logger.info(f"[Cycle #{iteration}] Processed {n} video(s).")
            else:
                logger.info(f"[Cycle #{iteration}] No new pending videos.")
        except Exception as e:
            logger.error(f"Scan cycle error: {e}", exc_info=True)

        if once:
            logger.info("--once flag set. Exiting.")
            break

        for _ in range(interval):
            if not RUNNING:
                break
            time.sleep(1)

    logger.info("EPIC Auto-Pipeline daemon stopped.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="EPIC Multi-Camera Video Pipeline Daemon")
    parser.add_argument("--interval", type=int, default=DEFAULT_POLL_INTERVAL)
    parser.add_argument("--once", action="store_true")
    parser.add_argument("--raw-dir", type=str, default=None)
    parser.add_argument("--processed-dir", type=str, default=None)
    parser.add_argument("--retry-errors", action="store_true")
    parser.add_argument("--max-workers", type=int, default=4,
                        help="Ignored (kept for CLI compatibility). Videos are processed one at a time; "
                             "see CHUNKS_PER_VIDEO for per-video GPU chunk parallelism.")
    args = parser.parse_args()

    run_daemon(
        interval=args.interval,
        once=args.once,
        raw_dir=args.raw_dir,
        processed_dir=args.processed_dir,
        retry_errors=args.retry_errors,
    )
