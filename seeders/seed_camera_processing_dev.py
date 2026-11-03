import sys
import os
import random
import argparse
from datetime import datetime, timedelta

sys.path.insert(0, os.path.normpath(os.path.join(os.path.dirname(__file__), "..")))

from database.database import (
    SessionLocal, Branch, Camera, Video, Event
)

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DAYS_BACK     = 90    
RNG_SEED      = 1024  
TAG           = "TST_CP_" 

random.seed(RNG_SEED)

BRANCHES = [
    {"name": f"{TAG}Karachi HQ", "address": "I.I. Chundrigar Road, Karachi", "manager_name": "Mr. Asim Raza"},
    {"name": f"{TAG}Lahore Regional", "address": "Gulberg III, Lahore", "manager_name": "Mr. Tariq Mehmood"},
    {"name": f"{TAG}Islamabad Corporate", "address": "Blue Area, Islamabad", "manager_name": "Ms. Sana Mirza"},
]

CAMERAS_PER_BRANCH = [
    {"suffix": "Main Entrance", "type": "attendance", "is_checkin": True, "is_checkout": True},
    {"suffix": "Back Exit", "type": "attendance", "is_checkin": False, "is_checkout": True},
]

STATUSES = [
    ("completed", 0.70), # 70% Pass
    ("failed", 0.15),    # 15% Fail
    ("retry", 0.10),     # 10% Retry
    ("processing", 0.05) # 5% Processing
]

def get_random_status():
    r = random.random()
    cumulative = 0.0
    for st, prob in STATUSES:
        cumulative += prob
        if r < cumulative:
            return st
    return "completed"

def purge_data(db):
    print(f"Purging existing {TAG} data...")
    
    # 1. Events associated with TST_CP_ Videos
    tst_vids = db.query(Video.id).filter(Video.filename.like(f"{TAG}%")).all()
    vid_ids = [v[0] for v in tst_vids]
    if vid_ids:
        db.query(Event).filter(Event.video_id.in_(vid_ids)).delete(synchronize_session=False)
        print(f"  - Purged Events linked to {TAG} Videos")
        
    # 2. Videos
    n_vids = db.query(Video).filter(Video.filename.like(f"{TAG}%")).delete(synchronize_session=False)
    print(f"  - Purged {n_vids} Videos")
    
    # 3. Cameras
    n_cams = db.query(Camera).filter(Camera.name.like(f"{TAG}%")).delete(synchronize_session=False)
    print(f"  - Purged {n_cams} Cameras")
    
    # 4. Branches
    n_branches = db.query(Branch).filter(Branch.name.like(f"{TAG}%")).delete(synchronize_session=False)
    print(f"  - Purged {n_branches} Branches")
    
    db.commit()
    print("Purge complete.\n")

def seed_data():
    db = SessionLocal()
    try:
        purge_data(db)
        
        print("Starting Seeder for Camera Processing Reports...")
        
        # 1. Create Branches
        branch_objs = []
        for bd in BRANCHES:
            b = Branch(
                name=bd["name"],
                address=bd["address"],
                manager_name=bd["manager_name"],
                status="active"
            )
            db.add(b)
            branch_objs.append(b)
        db.commit()
        for b in branch_objs:
            db.refresh(b)
            
        print(f"Created {len(branch_objs)} Branches.")
        
        # 2. Create Cameras
        camera_objs = []
        for b in branch_objs:
            for cd in CAMERAS_PER_BRANCH:
                cam_name = f"{TAG}{b.name.replace(TAG, '')} - {cd['suffix']}"
                c = Camera(
                    camera_id=f"CAM_{cam_name.replace(' ', '_').upper()}",
                    name=cam_name,
                    branch_id=b.id,
                    camera_type=cd["type"],
                    is_checkin=cd["is_checkin"],
                    is_checkout=cd["is_checkout"],
                    status="online"
                )
                db.add(c)
                camera_objs.append(c)
        db.commit()
        for c in camera_objs:
            db.refresh(c)
            
        print(f"Created {len(camera_objs)} Cameras.")
        
        # 3. Create Videos and Events for 90 days
        now = datetime.utcnow()
        v_count = 0
        e_count = 0
        
        # We simulate 1 video per camera per day
        for i in range(DAYS_BACK):
            current_date = now - timedelta(days=i)
            date_str = current_date.strftime("%Y-%m-%d")
            
            for cam in camera_objs:
                # Randomize if this camera processed a video on this day
                if random.random() < 0.1: # 10% chance of no video
                    continue
                    
                status = get_random_status()
                duration = round(random.uniform(1800, 28800)) # 30 mins to 8 hours
                
                v_name = f"{TAG}VID_{cam.name.replace(' ', '_')}_{date_str}.mp4"
                v = Video(
                    filename=v_name,
                    folder_type="mixed",
                    file_path=f"/dev_recordings/{v_name}",
                    file_size_mb=round(random.uniform(100, 1024), 1),
                    duration_seconds=duration,
                    resolution="1920x1080",
                    fps=25.0,
                    video_start_time=f"{date_str} 08:00:00",
                    camera_name=cam.name,
                    status=status,
                    created_at=current_date
                )
                db.add(v)
                db.commit()
                db.refresh(v)
                v_count += 1
                
                # Create detection events ONLY if status is completed
                if status == "completed":
                    # Generate random number of detections
                    num_checkin = random.randint(10, 50) if cam.is_checkin else 0
                    num_checkout = random.randint(10, 50) if cam.is_checkout else 0
                    
                    for _ in range(num_checkin):
                        ev = Event(
                            video_id=v.id,
                            camera_role="checkin",
                            track_id=random.randint(1000, 99999),
                            timestamp=f"{date_str} {random.randint(8,12):02d}:{random.randint(0,59):02d}:00",
                            frame_number=random.randint(0, duration * 25),
                            confidence=round(random.uniform(0.85, 0.99), 3),
                            status="completed",
                            created_at=current_date
                        )
                        db.add(ev)
                        e_count += 1
                        
                    for _ in range(num_checkout):
                        ev = Event(
                            video_id=v.id,
                            camera_role="checkout",
                            track_id=random.randint(1000, 99999),
                            timestamp=f"{date_str} {random.randint(13,18):02d}:{random.randint(0,59):02d}:00",
                            frame_number=random.randint(0, duration * 25),
                            confidence=round(random.uniform(0.85, 0.99), 3),
                            status="completed",
                            created_at=current_date
                        )
                        db.add(ev)
                        e_count += 1
                        
            # Commit every day to avoid massive transaction
            db.commit()
            
        print(f"Created {v_count} Video Processing Records.")
        print(f"Created {e_count} Detection Events.")
        print("\nSeeding completed successfully!")
        
    except Exception as e:
        print(f"Error during seeding: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seed Camera Processing test data.")
    parser.add_argument("--purge", action="store_true", help="Only purge the test data without seeding.")
    args = parser.parse_args()
    
    if args.purge:
        db = SessionLocal()
        purge_data(db)
        db.close()
    else:
        seed_data()
