"""
EPIC Scalable Celery Application
=================================
Provides background worker processing for video ingestion and AI analysis.
Uses Redis as the message broker.

Run worker with:
  celery -A celery_app.celery_app worker --loglevel=info
"""

import os
import sys
from celery import Celery

# Ensure backend directory is in sys.path
BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)

# Load configuration settings
try:
    from config.settings import cfg
except ImportError:
    cfg = {}

# Retrieve Redis URL from environment or configuration
REDIS_URL = os.getenv("CELERY_BROKER_URL") or cfg.get("celery", {}).get("broker_url") or "redis://localhost:6379/0"

# Initialize Celery app
celery_app = Celery(
    "epic_tasks",
    broker=REDIS_URL,
    backend=REDIS_URL,
)

# Optional configuration settings
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=86400, # Max 24 hours per task
)


@celery_app.task(name="celery_app.process_video_task", bind=True)
def process_video_task(self, video_id: int, output_dir: str):
    """
    Background worker task to process a single video using the integrated AI pipeline.
    """
    print(f"[Celery Worker] Starting task for Video ID #{video_id}")
    
    from database.database import SessionLocal, Video
    from integrated_pipeline import process_video_single_pass, get_insightface_app, load_enrolled_employees
    
    db = SessionLocal()
    video_record = db.query(Video).filter(Video.id == video_id).first()
    
    if not video_record:
        print(f"[Celery Worker ERROR] Video ID #{video_id} not found in DB!")
        db.close()
        return {"status": "error", "message": f"Video ID #{video_id} not found"}
        
    try:
        # Update status in db to processing
        video_record.status = "processing"
        db.commit()
        
        # Lazy load model singletons inside worker process
        print("[Celery Worker] Loading AI models (YOLO & InsightFace)...")
        app = get_insightface_app()
        enrolled = load_enrolled_employees()
        
        # Process video
        summary = process_video_single_pass(
            video_record=video_record,
            db=db,
            app=app,
            enrolled_employees=enrolled,
            output_dir=output_dir,
            show_live=False
        )
        
        # Update status to completed
        video_record.status = "completed"
        db.commit()
        
        print(f"[Celery Worker] Successfully processed Video ID #{video_id}. Saved to {summary.get('output_path')}")
        return {"status": "completed", "video_id": video_id, "output_path": summary.get("output_path")}
        
    except Exception as e:
        db.rollback()
        video_record.status = "error"
        # Save error message to DB if schema allows it
        if hasattr(video_record, "error_message"):
            video_record.error_message = str(e)[:500]
        try:
            db.commit()
        except Exception:
            pass
            
        print(f"[Celery Worker ERROR] Failed processing Video ID #{video_id}: {e}")
        import traceback
        traceback.print_exc()
        raise e
        
    finally:
        db.close()
