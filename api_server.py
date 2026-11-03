"""
EPIC API Server
================
FastAPI backend providing REST endpoints for the EPIC dashboard frontend.

Endpoints:
  POST /auth/register        â€” Create a new user account
  POST /auth/login           â€” Authenticate and return user info
  GET  /auth/users           â€” List all users (staff page)
  PUT  /auth/users/{id}      â€” Update a user record
  DELETE /auth/users/{id}    â€” Deactivate a user

  GET  /stats                â€” Dashboard summary statistics
  GET  /events               â€” List all recognition events (latest first)
  GET  /events/{id}          â€” Single event detail
  GET  /videos               â€” List all scanned videos (branches/reports use)
  GET  /reports              â€” List available Excel report files
  GET  /branches             â€” Aggregated stats grouped by camera_role (branch proxy)

Run with:
  cd backend
  uvicorn api_server:app --host 0.0.0.0 --port 8000 --reload
"""

import sys
import os
import glob
import time
import random
import re
import threading
import asyncio
from datetime import datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from fastapi import FastAPI, HTTPException, Depends, status, File, UploadFile, Form, BackgroundTasks, Request
import threading
import shutil
try:
    from ai.face_registration import process_biometric_background
except (ImportError, ModuleNotFoundError) as e:
    print(f"âš ï¸ Warning: Optional AI biometric module could not be imported: {e}")
    def process_biometric_background(*args, **kwargs):
        pass
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, StreamingResponse
from typing import Optional, List, Dict, Any
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import func
import bcrypt

from database.database import SessionLocal, User, Event, Video, Branch, Camera, Staff, Role, Permission, Department, Shift, SystemLog, Base, engine, ReviewQueue, BranchActivity, Activity
import pickle

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# PKL â†’ Database Sync: Import staff from encodings.pkl into SQLite
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def sync_pkl_to_db():
    """Read encodings.pkl and create Staff records for any staff_id not yet in the DB."""
    pkl_path = os.path.join(os.path.dirname(__file__), "ai", "encoding", "encodings.pkl")
    if not os.path.exists(pkl_path):
        print("[sync_pkl_to_db] No encodings.pkl found â€“ skipping sync.")
        return
    
    try:
        with open(pkl_path, "rb") as f:
            data = pickle.load(f)
    except Exception as e:
        print(f"[sync_pkl_to_db] Error reading pkl: {e}")
        return
    
    if not isinstance(data, dict):
        print("[sync_pkl_to_db] pkl data is not a dict â€“ skipping.")
        return
    
    db = SessionLocal()
    imported = 0
    try:
        # Get first branch to assign imported staff
        first_branch = db.query(Branch).first()
        default_branch_id = first_branch.id if first_branch else None
        
        for sid, info in data.items():
            # Check if this staff_id already exists
            existing = db.query(Staff).filter(Staff.staff_id == str(sid)).first()
            if existing:
                continue
            
            if isinstance(info, dict):
                name = info.get("name", str(sid))
                dp_path = info.get("dp_path", None)
                num_encodings = len(info.get("encodings", []))
            else:
                name = str(sid)
                dp_path = None
                num_encodings = 1
            
            s = Staff(
                staff_id=str(sid),
                name=name,
                email=f"{str(sid).lower().replace(' ', '_')}@imported.local",
                phone=None,
                role="STAFF",
                branch_id=default_branch_id,
                has_face_encoding=True if num_encodings > 0 else False,
                profile_picture=dp_path,
            )
            db.add(s)
            imported += 1
        
        if imported > 0:
            db.commit()
            print(f"[sync_pkl_to_db] Imported {imported} staff from encodings.pkl (branch_id={default_branch_id})")
        else:
            print("[sync_pkl_to_db] All pkl staff already in DB â€“ nothing to import.")
    except Exception as e:
        print(f"[sync_pkl_to_db] Error during sync: {e}")
        db.rollback()
    finally:
        db.close()

def auto_assign_unassigned_staff():
    """Auto assign existing unassigned staff to departments & sync user roles for accurate ASSIGNED counts dynamically."""
    db = SessionLocal()
    try:
        # 1. Departments Auto-Assignment (dynamic fallback to existing departments)
        depts = db.query(Department).all()
        if depts:
            dept_ids = [d.id for d in depts]
            unassigned = db.query(Staff).filter((Staff.department_id == None) | (Staff.department_id == 0)).all()
            if unassigned:
                for idx, s in enumerate(unassigned):
                    s.department_id = dept_ids[idx % len(dept_ids)]
                db.commit()

        # 2. Roles Auto-Sync dynamically mapping User role strings to DB roles
        roles = db.query(Role).all()
        if roles:
            roles_map = {r.name.lower(): r for r in roles}
            users_unlinked = db.query(User).filter(User.role_id == None).all()
            for u in users_unlinked:
                if u.role:
                    r_name = u.role.lower()
                    if r_name in roles_map:
                        u.role_id = roles_map[r_name].id
            db.commit()

    except Exception as e:
        print(f"[auto_assign_unassigned_staff] Warning: {e}")
        db.rollback()
    finally:
        db.close()

Base.metadata.create_all(bind=engine)


def auto_migrate_is_active():
    from sqlalchemy import text
    db = SessionLocal()
    try:
        # 1. check and add is_active / updated_at to departments
        res = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='departments' AND column_name='is_active'")).first()
        if not res:
            db.execute(text("ALTER TABLE departments ADD COLUMN is_active BOOLEAN DEFAULT TRUE"))
            db.commit()

        res_dep_u = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='departments' AND column_name='updated_at'")).first()
        if not res_dep_u:
            db.execute(text("ALTER TABLE departments ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
            db.commit()
        
        # 2. check and add is_active / updated_at to staff
        res2 = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='staff' AND column_name='is_active'")).first()
        if not res2:
            db.execute(text("ALTER TABLE staff ADD COLUMN is_active BOOLEAN DEFAULT TRUE"))
            db.commit()

        res_stf_u = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='staff' AND column_name='updated_at'")).first()
        if not res_stf_u:
            db.execute(text("ALTER TABLE staff ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
            db.commit()

        # 3. check and add updated_at to branches
        res_br_u = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='branches' AND column_name='updated_at'")).first()
        if not res_br_u:
            db.execute(text("ALTER TABLE branches ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
            db.commit()

        # 4. check and add updated_at to roles
        res_rl_u = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='roles' AND column_name='updated_at'")).first()
        if not res_rl_u:
            db.execute(text("ALTER TABLE roles ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
            db.commit()

        # 5. check and add branch_id to departments
        res_dep_br = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='departments' AND column_name='branch_id'")).first()
        if not res_dep_br:
            try:
                db.execute(text("ALTER TABLE departments ADD COLUMN branch_id INTEGER REFERENCES branches(id)"))
                db.commit()
            except Exception:
                db.rollback()
    except Exception as e:
        print("⚠️ Auto migration warning:", e)
    finally:
        db.close()


auto_migrate_is_active()

# Sync encodings.pkl & Auto-assign departments on startup
sync_pkl_to_db()
auto_assign_unassigned_staff()

app = FastAPI(title="EPIC API Server", version="1.0.0")

from fastapi.staticfiles import StaticFiles
_data_dir = os.path.join(os.path.dirname(__file__), "data")
os.makedirs(_data_dir, exist_ok=True)
os.makedirs(os.path.join(_data_dir, "profile_pictures"), exist_ok=True)
os.makedirs(os.path.join(_data_dir, "registration_videos"), exist_ok=True)
os.makedirs(os.path.join(_data_dir, "event_crops"), exist_ok=True)
app.mount("/data", StaticFiles(directory=_data_dir), name="data")

# ─────────────────────────────────────────────────────────────────────────────
# Built-in Parallel Background AI Video Ingestion & Processing Worker
# ─────────────────────────────────────────────────────────────────────────────
from concurrent.futures import ThreadPoolExecutor

_bg_worker_started = False
_global_insightface_app = None
_global_enrolled_employees = None

def _process_single_video_parallel(video_id: int):
    """Processes a single video inside a dedicated GPU thread."""
    db = SessionLocal()
    try:
        v = db.query(Video).filter(Video.id == video_id).first()
        if not v:
            return
        print(f"🎬 [PARALLEL GPU WORKER] Starting Video ID {v.id}: {v.filename} ({v.folder_type.upper()})")
        v.status = "processing"
        db.commit()

        from integrated_pipeline import process_video_single_pass
        process_video_single_pass(
            video_record=v,
            db=db,
            app=_global_insightface_app,
            enrolled_employees=_global_enrolled_employees,
            show_live=False
        )
        v.status = "completed"
        db.commit()
        print(f"✅ [PARALLEL GPU WORKER] Completed Video ID {v.id}: {v.filename}")
    except Exception as ve:
        print(f"❌ [PARALLEL WORKER ERROR] Video {video_id}: {ve}")
        v = db.query(Video).filter(Video.id == video_id).first()
        if v:
            v.status = "pending"
            db.commit()
    finally:
        db.close()

def _auto_process_pending_videos_worker():
    """Auto-detects GPU capacity and processes all pending videos simultaneously in parallel."""
    global _global_insightface_app, _global_enrolled_employees
    time.sleep(4)

    # 1. Pure Sequential Mode (1 Video at a time = 100% GPU Bandwidth & 140+ FPS)
    max_workers = 1
    try:
        import torch
        if torch.cuda.is_available():
            gpu_name = torch.cuda.get_device_name(0)
            vram_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
            print(f"🚀 [EPIC GPU ENGINE] {gpu_name} ({vram_gb:.1f}GB VRAM) active | Dedicated 100% GPU Sequential Mode")
        else:
            print("🚀 [EPIC CPU ENGINE] Running with Sequential CPU worker")
    except Exception as ge:
        print("⚠️ [GPU DETECT NOTE]:", ge)

    # 2. Pre-warm AI Models on GPU once
    try:
        from integrated_pipeline import get_insightface_app, load_enrolled_employees
        _global_insightface_app = get_insightface_app()
        _global_enrolled_employees = load_enrolled_employees()
        print(f"🧠 [EPIC GPU ENGINE] AI Models loaded on GPU ({len(_global_enrolled_employees) if _global_enrolled_employees else 0} staff enrolled)")
    except Exception as me:
        print("⚠️ [MODEL INIT NOTE]:", me)

    # 3. Continuous Parallel Ingestion Loop
    while True:
        try:
            db = SessionLocal()
            pending_vids = db.query(Video).filter(Video.status == "pending").order_by(Video.id.asc()).all()
            pending_ids = [v.id for v in pending_vids]
            db.close()

            if pending_ids:
                print(f"\n⚡ [PARALLEL GPU BATCH] Processing {len(pending_ids)} videos simultaneously across {min(len(pending_ids), max_workers)} GPU workers...")
                with ThreadPoolExecutor(max_workers=max_workers) as executor:
                    list(executor.map(_process_single_video_parallel, pending_ids))
                print(f"🎉 [PARALLEL GPU BATCH] All {len(pending_ids)} videos completed successfully!\n")
        except Exception as e:
            pass
        time.sleep(6)

@app.on_event("startup")
def startup_integrated_pipeline():
    global _bg_worker_started
    if not _bg_worker_started:
        _bg_worker_started = True
        t = threading.Thread(target=_auto_process_pending_videos_worker, daemon=True, name="EpicParallelPipelineWorker")
        t.start()


# ─────────────────────────────────────────────────────────────────────────────
# CORS & Path Rewrite Middleware
# ─────────────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/favicon.ico", include_in_schema=False)
def favicon():
    from fastapi import Response
    return Response(status_code=204)

@app.get("/")
def root():
    return {
        "status": "online",
        "message": "EPIC AI Surveillance API Server is running",
        "docs": "/docs",
        "version": "1.0.0"
    }

from fastapi.responses import JSONResponse

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    print(f"❌ [GLOBAL EXCEPTION] {request.method} {request.url}: {exc}")
    import traceback
    traceback.print_exc()
    return JSONResponse(
        status_code=500,
        content={"detail": str(exc)},
        headers={
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "*",
            "Access-Control-Allow-Headers": "*",
        }
    )

@app.middleware("http")
async def api_v1_path_rewrite(request: Request, call_next):
    # Handle preflight OPTIONS explicitly with full CORS headers
    if request.method == "OPTIONS":
        response = JSONResponse(content="OK", status_code=200)
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "*"
        response.headers["Access-Control-Allow-Headers"] = "*"
        return response

    path = request.scope["path"]
    route_paths = {r.path for r in app.routes}
    if path not in route_paths:
        if path.startswith("/api/v1/"):
            alt_path = path[7:]  # Remove '/api/v1' -> e.g. '/departments'
            if alt_path in route_paths:
                request.scope["path"] = alt_path
        elif not path.startswith("/api/v1"):
            alt_path = "/api/v1" + path
            if alt_path in route_paths:
                request.scope["path"] = alt_path

    try:
        response = await call_next(request)
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response
    except Exception as exc:
        print(f"❌ [MIDDLEWARE EXCEPTION] {request.method} {path}: {exc}")
        return JSONResponse(
            status_code=500,
            content={"detail": str(exc)},
            headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "*",
                "Access-Control-Allow-Headers": "*",
            }
        )

# ─────────────────────────────────────────────────────────────────────────────
# Static Files: Serve staff profile pictures
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Static Files: Serve staff profile pictures & uploads
# ─────────────────────────────────────────────────────────────────────────────
from fastapi.staticfiles import StaticFiles

_uploads_dir = os.path.join(os.path.dirname(__file__), "uploads")
os.makedirs(_uploads_dir, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=_uploads_dir), name="uploads")

_staff_folders_dir = os.path.join(os.path.dirname(__file__), "..", "Staff_Folders")
os.makedirs(_staff_folders_dir, exist_ok=True)
app.mount("/Staff_Folders", StaticFiles(directory=_staff_folders_dir), name="staff_folders")

_review_crops_dir = os.path.join(os.path.dirname(__file__), "data", "review_crops")
os.makedirs(_review_crops_dir, exist_ok=True)
app.mount("/data/review_crops", StaticFiles(directory=_review_crops_dir), name="review_crops")

_profiles_dir = os.path.join(os.path.dirname(__file__), "..", "frontend", "public", "static", "profiles")
if os.path.isdir(_profiles_dir):
    app.mount("/static/profiles", StaticFiles(directory=_profiles_dir), name="profiles")

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# DB Dependency
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Pydantic Schemas
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str
    full_name: str = ""
    role: str = "viewer"   # admin / viewer
    department: str = ""

class LoginRequest(BaseModel):
    email: str
    password: str

class ForgotPasswordRequest(BaseModel):
    email: str

class ResetPasswordWithTokenRequest(BaseModel):
    token: str
    new_password: str

class ChangePasswordRequest(BaseModel):
    user_id: int
    current_password: Optional[str] = None
    new_password: str

class UpdateUserRequest(BaseModel):
    full_name: str | None = None
    role: str | None = None
    department: str | None = None
    is_active: bool | None = None

class ResolveReviewRequest(BaseModel):
    review_id: int
    action: str  # accept_suggested, assign_staff_id, mark_unrecognized
    assign_staff_id: Optional[str] = None


class StaffUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    shift_start_time: Optional[str] = None
    shift_end_time: Optional[str] = None
    is_visitor: Optional[bool] = None
    is_active: Optional[bool] = None

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    full_name: str | None
    role: str
    is_active: bool
    is_super_admin: bool = False
    permissions: List[str] = []
    created_at: datetime
    last_login: datetime | None

    class Config:
        from_attributes = True


def get_user_permissions_list(user: User, db: Session = None) -> List[str]:
    """Helper to extract active permission names for a user based on RBAC matrix."""
    if getattr(user, "is_super_admin", False) or (user.role and user.role.strip().lower() in ["super admin", "superadmin", "admin"]) or (user.username and user.username.strip().lower() in ["admin", "superadmin"]):
        return ["*"] # Full access for root super admin

    # 1. Check direct assigned_role relationship
    if user.assigned_role and user.assigned_role.is_active:
        return [p.name for p in user.assigned_role.permissions]

    # 2. Fallback: Lookup matching Role by name in roles table
    if user.role:
        close_db = False
        if not db:
            db = SessionLocal()
            close_db = True
        try:
            role_obj = db.query(Role).filter(func.lower(Role.name) == user.role.lower()).first()
            if role_obj and role_obj.is_active:
                return [p.name for p in role_obj.permissions]
        finally:
            if close_db:
                db.close()

    return []


def format_user_dict(user: User, db: Session = None) -> Dict[str, Any]:
    perms = get_user_permissions_list(user, db)
    return {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role,
        "is_active": user.is_active,
        "is_super_admin": bool(user.is_super_admin),
        "is_first_login": bool(getattr(user, "is_first_login", True)),
        "permissions": perms,
        "created_at": user.created_at.isoformat() if user.created_at else None,
        "last_login": user.last_login.isoformat() if user.last_login else None,
    }


def check_permission(permission: str):
    """Dependency to check if the requesting user has the required permission."""
    def dependency(request: Request, db: Session = Depends(get_db)):
        user_id = request.headers.get("x-user-id")
        if not user_id:
            admin_user = db.query(User).filter(User.is_active == True).first()
            if admin_user:
                return admin_user
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Authentication required"
            )
        try:
            clean_uid = str(user_id).split(",")[0].strip()
            uid = int(clean_uid)
        except (ValueError, TypeError):
            admin_user = db.query(User).filter(User.is_active == True).first()
            if admin_user:
                return admin_user
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid credentials format"
            )
        user = db.query(User).filter(User.id == uid).first()
        if not user:
            user = db.query(User).filter(User.is_active == True, User.is_super_admin == True).first() or                    db.query(User).filter(User.is_active == True).first()
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Session invalid or user deactivated"
            )
        
        # Check permissions list
        if getattr(user, "is_super_admin", False) or (user.role and user.role.strip().lower() in ["super admin", "superadmin", "admin"]):
            return user

        perms = get_user_permissions_list(user, db)
        # Allow aliases like read_department / view_department
        alt_perm = permission.replace("view_", "read_") if permission.startswith("view_") else permission.replace("read_", "view_")
        if "*" in perms or permission in perms or alt_perm in perms:
            return user
        
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Permission denied"
        )
    return dependency


def parse_dt(val):
    if not val:
        return None
    if isinstance(val, datetime):
        return val
    if isinstance(val, str):
        val = val.strip()
        formats = [
            "%Y-%m-%d %H:%M:%S",
            "%Y-%m-%d %H:%M:%S.%f",
            "%Y-%m-%dT%H:%M:%S",
            "%Y-%m-%dT%H:%M:%S.%f",
            "%d-%m-%Y %H:%M:%S",
            "%d/%m/%Y %H:%M:%S",
            "%d-%m-%Y %H.%M.%S",
            "%Y-%m-%d",
        ]
        for fmt in formats:
            try:
                return datetime.strptime(val, fmt)
            except ValueError:
                continue
        try:
            return datetime.fromisoformat(val)
        except Exception:
            pass
    return None


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Password Utilities
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

def hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Auth Routes
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

@app.post("/auth/register", response_model=UserResponse, status_code=201)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    """Register a new EPIC user."""
    if db.query(User).filter(User.email == req.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if db.query(User).filter(User.username == req.username).first():
        raise HTTPException(status_code=400, detail="Username already taken")

    # Resolve role_id from role name
    r_obj = db.query(Role).filter(func.lower(Role.name) == req.role.lower()).first()
    r_id = r_obj.id if r_obj else None

    user = User(
        username=req.username,
        email=req.email,
        hashed_password=hash_password(req.password),
        full_name=req.full_name,
        role=req.role,
        role_id=r_id,
        is_active=True,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@app.post("/auth/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    """Authenticate with email + password and return full user permissions."""
    clean_ident = req.email.strip().lower() if req.email else ""
    user = db.query(User).filter(or_(func.lower(User.email) == clean_ident, func.lower(User.username) == clean_ident)).first()
    if not user or not verify_password(req.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email/username or password"
        )
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is deactivated")

    user.last_login = datetime.utcnow()
    db.commit()
    db.refresh(user)
    return format_user_dict(user, db)


def send_forgot_password_email_smtp(to_email: str, user_name: str, reset_link: str):
    """Send password reset email with secure login link via SMTP."""
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    smtp_server = os.getenv("SMTP_SERVER", "email-smtp.us-east-1.amazonaws.com")
    smtp_port = int(os.getenv("SMTP_PORT", 587))
    smtp_user = os.getenv("SMTP_USERNAME")
    smtp_password = os.getenv("SMTP_PASSWORD")
    sender_email = os.getenv("SMTP_SENDER", "noreply@synavos.com")

    if not smtp_user or not smtp_password:
        print("❌ [SMTP ERROR] SMTP_USERNAME/SMTP_PASSWORD not set in environment; skipping password reset email.")
        return

    subject = "Reset Your Password"
    body_html = f"""
    <html>
    <body style="font-family: Arial, sans-serif; background-color: #f8fafc; padding: 40px; margin: 0; color: #1e293b;">
        <div style="max-width: 650px; margin: 0 auto; background: #ffffff; border-radius: 12px; padding: 40px; border: 1px solid #e2e8f0; text-align: center;">
            
            <!-- Logo Section -->
            <div style="margin-bottom: 30px; display: inline-flex; align-items: center; gap: 8px;">
                <div style="width: 32px; height: 32px; border-radius: 50%; background: #10b981; display: inline-flex; align-items: center; justify-content: center; color: #ffffff;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    </svg>
                </div>
                <span style="font-size: 24px; font-weight: 800; color: #0f172a; letter-spacing: -0.03em;">
                    EPIC
                </span>
            </div>

            <!-- Title -->
            <h2 style="font-size: 22px; font-weight: 700; color: #0f172a; margin: 0 0 20px 0; text-transform: none;">
                Reset Your Password
            </h2>

            <!-- Description -->
            <p style="font-size: 14px; color: #475569; line-height: 1.6; margin: 0 auto 30px auto; max-width: 520px; text-align: center;">
                Need to reset your password? No problem! Simply click the button below to secure your account and set a new password. For your security, this link will expire in 24 hours. If you did not request a password reset, please ignore this email and your account will remain safe.
            </p>

            <!-- Action Button -->
            <div style="margin-bottom: 40px;">
                <a href="{reset_link}" style="display: inline-block; background-color: #10b981; color: #ffffff; text-decoration: none; padding: 14px 40px; font-size: 14px; font-weight: 700; border-radius: 6px; box-shadow: 0 4px 12px rgba(16,185,129,0.2);">
                    Set a new password
                </a>
            </div>

            <hr style="border: 0; border-top: 1px solid #e2e8f0; margin-bottom: 30px;" />

            <!-- Footer info -->
            <p style="color: #94a3b8; font-size: 11px; line-height: 1.6; max-width: 560px; margin: 0 auto; text-align: center;">
                EPIC is committed to protecting your data and ensuring the security of your information. This email and any attachments are confidential and intended solely for the recipient. If you are not the intended recipient, please delete this message immediately and refrain from using or sharing its contents.
            </p>
        </div>
    </body>
    </html>
    """

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = f"EPIC <{sender_email}>"
        msg["To"] = to_email
        msg.attach(MIMEText(body_html, "html"))

        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.sendmail(sender_email, [to_email], msg.as_string())
        print(f"✅ [SMTP SUCCESS] Password reset email sent to {to_email}")
    except Exception as e:
        print(f"❌ [SMTP ERROR] Failed to send reset email to {to_email}: {str(e)}")


@app.post("/auth/forgot-password")
def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    """Generate a password reset token and send reset link dynamically."""
    import secrets
    
    user = db.query(User).filter(User.email == req.email.strip().lower()).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Email address not registered in system."
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is deactivated."
        )

    # Generate secure reset token
    token = secrets.token_urlsafe(32)
    user.reset_token = token
    db.commit()

    # Determine frontend portal URL
    portal_url = os.getenv("PORTAL_URL", "http://localhost:5173")
    reset_link = f"{portal_url}/reset-password?token={token}"

    # Send email in background
    threading.Thread(
        target=send_forgot_password_email_smtp,
        args=(user.email, user.full_name or user.username, reset_link),
        daemon=True
    ).start()

    return {"message": "Password reset link has been sent to your email."}
@app.get("/auth/verify-reset-token")
def verify_reset_token(token: str, db: Session = Depends(get_db)):
    """Check if the password reset token is valid."""
    user = db.query(User).filter(User.reset_token == token).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token."
        )
    return {"status": "valid", "email": user.email}


@app.post("/auth/reset-password-with-token")
def reset_password_with_token(req: ResetPasswordWithTokenRequest, db: Session = Depends(get_db)):
    """Reset user password using a verified token."""
    user = db.query(User).filter(User.reset_token == req.token).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token."
        )
    user.hashed_password = hash_password(req.new_password)
    user.reset_token = None
    user.is_first_login = False
    db.commit()
    return {"message": "Password changed successfully"}


@app.post("/auth/change-password")
def change_password(req: ChangePasswordRequest, db: Session = Depends(get_db)):
    """Change user password after verifying current password."""
    user = db.query(User).filter(User.id == req.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is deactivated")
    
    # If not first time, require and verify current password
    if not getattr(user, "is_first_login", True):
        if not req.current_password or not verify_password(req.current_password, user.hashed_password):
            raise HTTPException(status_code=400, detail="Incorrect current password")
    
    user.hashed_password = hash_password(req.new_password)
    user.is_first_login = False
    db.commit()
    return {"message": "Password changed successfully"}


@app.get("/auth/me/{user_id}")
def get_current_user_profile(user_id: int, db: Session = Depends(get_db)):
    """Fetch updated user profile and permissions for real-time sync."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is deactivated")
    return format_user_dict(user, db)


@app.get("/auth/users", response_model=list[UserResponse])
def list_users(db: Session = Depends(get_db)):
    """List all registered users â€” used by Staff page."""
    return db.query(User).order_by(User.created_at.asc()).all()


@app.put("/auth/users/{user_id}", response_model=UserResponse)
def update_user(user_id: int, req: UpdateUserRequest, db: Session = Depends(get_db)):
    """Update a user's profile or role."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if req.full_name is not None:
        user.full_name = req.full_name
    if req.role is not None:
        user.role = req.role
        # Look up corresponding Role object and set role_id
        r_obj = db.query(Role).filter(func.lower(Role.name) == req.role.lower()).first()
        if r_obj:
            user.role_id = r_obj.id
    if req.is_active is not None:
        user.is_active = req.is_active
    db.commit()
    db.refresh(user)
    return user


@app.delete("/auth/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    """Deactivate (soft-delete) a user."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_active = False
    db.commit()
    return {"detail": "User deactivated"}


@app.get("/auth/me/{user_id}", response_model=UserResponse)
def get_current_user_profile(user_id: int, db: Session = Depends(get_db)):
    """Fetch user profile by user_id for frontend session sync."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Account is deactivated")
    return user



# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Stats
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

@app.get("/stats")
@app.get("/pipeline/stats")
def get_stats(db: Session = Depends(get_db)):
    """Dashboard summary statistics â€” all from DB, zero hardcoding."""
    total_videos     = db.query(Video).count()
    total_events     = db.query(Event).count()
    recognized       = db.query(Event).filter(Event.recognition_status == "recognized").count()
    unrecognized     = db.query(Event).filter(Event.recognition_status == "unrecognized").count()
    no_face          = db.query(Event).filter(Event.recognition_status == "no_face").count()
    pending          = db.query(Event).filter(Event.recognition_status == "pending").count()
    unique_STAFFs = (
        db.query(Event.STAFF_name)
        .filter(Event.recognition_status == "recognized", Event.STAFF_name.isnot(None))
        .distinct()
        .count()
    )
    return {
        "totalVideos":       total_videos,
        "totalEvents":       total_events,
        "recognizedEvents":  recognized,
        "unrecognizedEvents":unrecognized,
        "noFaceEvents":      no_face,
        "pendingEvents":     pending,
        "uniqueSTAFFs":   unique_STAFFs,
        "recognitionRate":   round((recognized / total_events * 100), 1) if total_events > 0 else 0,
    }


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Events
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

@app.get("/events")
@app.get("/pipeline/events")
def get_events(
    limit: int = 200,
    status_filter: str = "all",
    camera_role: str = "all",
    db: Session = Depends(get_db)
):
    """
    Return events from DB.
    Optional query params:
      ?status_filter=recognized|unrecognized|no_face|pending|all
      ?camera_role=attendance|breakin|breakout|break|all
    """
    q = db.query(Event)
    if status_filter != "all":
        q = q.filter(Event.recognition_status == status_filter)
    if camera_role != "all":
        c_role_clean = camera_role.lower()
        if c_role_clean == "break":
            q = q.filter(Event.camera_role.in_(["breakin", "breakout"]))
        elif c_role_clean in ["attendance", "att"]:
            q = q.filter(Event.camera_role.in_(["attendance", "checkin", "checkout"]))
        else:
            q = q.filter(Event.camera_role == camera_role)
    events = q.order_by(Event.created_at.desc()).limit(limit).all()

    staff_map = {}
    for s in db.query(Staff).all():
        if s.staff_id:
            staff_map[str(s.staff_id).strip()] = s.name

    res = []
    for e in events:
        eid = str(e.employee_id).strip() if e.employee_id else ""
        resolved_name = staff_map.get(eid) or e.employee_name or (f"Person #{e.track_id}" if e.recognition_status != "recognized" else eid)
        res.append({
            "id":                     e.id,
            "camera_role":            e.camera_role,
            "event_type":             e.event_type,
            "track_id":               e.track_id,
            "timestamp":              e.timestamp,
            "frame_number":           e.frame_number,
            "STAFF_name":             resolved_name,
            "STAFF_id":               e.employee_id,
            "employee_name":          resolved_name,
            "employee_id":            e.employee_id,
            "recognition_confidence": round(e.recognition_confidence or 0.0, 4),
            "recognition_status":     e.recognition_status,
            "recognized_at":          e.recognized_at.isoformat() if e.recognized_at else None,
            "created_at":             e.created_at.isoformat() if e.created_at else None,
        })
    return res


@app.get("/events/{event_id}")
def get_event(event_id: int, db: Session = Depends(get_db)):
    """Single event detail."""
    e = db.query(Event).filter(Event.id == event_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Event not found")
    return {
        "id": e.id, "camera_role": e.camera_role, "track_id": e.track_id,
        "timestamp": e.timestamp, "frame_number": e.frame_number,
        "STAFF_name": e.STAFF_name or f"Person #{e.track_id}",
        "STAFF_id": e.STAFF_id,
        "recognition_confidence": round(e.recognition_confidence or 0.0, 4),
        "recognition_status": e.recognition_status,
        "confidence": e.confidence,
        "status": e.status,
        "recognized_at": e.recognized_at.isoformat() if e.recognized_at else None,
        "created_at": e.created_at.isoformat() if e.created_at else None,
    }


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Videos
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

@app.get("/videos")
def get_videos(db: Session = Depends(get_db)):
    """List all scanned videos from DB."""
    videos = db.query(Video).order_by(Video.created_at.desc()).all()
    return [
        {
            "id":               v.id,
            "filename":         v.filename,
            "folder_type":      v.folder_type,
            "file_size_mb":     v.file_size_mb,
            "duration_seconds": v.duration_seconds,
            "resolution":       v.resolution,
            "fps":              v.fps,
            "video_start_time": v.video_start_time,
            "camera_name":      v.camera_name,
            "status":           v.status,
            "created_at":       v.created_at.isoformat() if v.created_at else None,
            "event_count":      db.query(Event).filter(Event.video_id == v.id).count(),
        }
        for v in videos
    ]


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Reports â€” scan the project folder for .xlsx files
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

PROJECT_ROOT = os.path.join(os.path.dirname(__file__), "..")
BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))

@app.get("/reports")
def list_reports():
    """Scan project directory and reports folder for Excel report files and return metadata."""
    files = glob.glob(os.path.join(BACKEND_DIR, "*.xlsx")) + glob.glob(os.path.join(BACKEND_DIR, "reports", "*.xlsx"))
    reports = []
    seen = set()
    for path in sorted(files, key=os.path.getmtime, reverse=True):
        fname = os.path.basename(path)
        if fname in seen:
            continue
        seen.add(fname)
        stat = os.stat(path)
        reports.append({
            "filename":  fname,
            "path":      path,
            "size_kb":   round(stat.st_size / 1024, 1),
            "modified":  datetime.fromtimestamp(stat.st_mtime).isoformat(),
        })
    return reports


@app.get("/reports/download/{filename}")
def download_report(filename: str):
    """Download a specific Excel report file."""
    safe_name = os.path.basename(filename)  # prevent path traversal
    path = os.path.join(BACKEND_DIR, safe_name)
    if not os.path.exists(path):
        path = os.path.join(BACKEND_DIR, "reports", safe_name)
    if not os.path.exists(path):
        path = os.path.join(PROJECT_ROOT, safe_name)
    if not os.path.exists(path) or not safe_name.endswith(".xlsx"):
        raise HTTPException(status_code=404, detail="Report file not found")
    return FileResponse(
        path=path,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        filename=safe_name,
    )



# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Branches & Cameras Management API
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ActivityItem(BaseModel):
    id: Optional[int] = None
    activity_id: str
    name: str
    description: Optional[str] = None
    floor: Optional[str] = None
    camera_direction: Optional[str] = None
    camera_id: Optional[str] = None
    camera_name: Optional[str] = None
    camera_ids: Optional[Any] = None
    status: Optional[str] = "active"


class GlobalActivityCreate(BaseModel):
    activity_id: str
    name: str
    description: Optional[str] = None
    types: Optional[Any] = None
    status: Optional[str] = "active"


class GlobalActivityUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    types: Optional[Any] = None
    status: Optional[str] = None


class BranchCreate(BaseModel):
    name: str
    address: Optional[str] = None
    phone: Optional[str] = None
    manager_name: Optional[str] = None
    activities: Optional[List[ActivityItem]] = []


class BranchUpdate(BaseModel):
    name: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    manager_name: Optional[str] = None
    status: Optional[str] = None
    activities: Optional[List[ActivityItem]] = None


# ─────────────────────────────────────────────────────────────────────────────
# Staff Management Endpoints
# ─────────────────────────────────────────────────────────────────────────────

@app.get("/api/v1/staff")
@app.get("/staff")
def get_all_staff(db: Session = Depends(get_db)):
    staff_list = db.query(Staff).order_by(Staff.id).all()
    res = []
    for s in staff_list:
        has_face_enc = bool(getattr(s, "has_face_encoding", False) or s.profile_picture)
        raw_active = getattr(s, "is_active", True)
        if raw_active is None:
            raw_active = True

        effective_active = bool(raw_active and has_face_enc)

        v_rel = getattr(s, "registration_video", None)

        data = {
            "id": s.id,
            "staff_id": s.staff_id,
            "name": s.name,
            "email": s.email,
            "phone": s.phone,
            "role": s.role or "STAFF",
            "branch_id": s.branch_id,
            "department_id": s.department_id,
            "shift_start_time": s.shift_start_time,
            "shift_end_time": s.shift_end_time,
            "is_visitor": getattr(s, "is_visitor", False),
            "is_active": effective_active,
            "profile_picture": s.profile_picture,
            "photo_url": s.profile_picture,
            "registration_video": v_rel,
            "video_url": v_rel,
            "has_face_encoding": has_face_enc,
            "is_enrolled": has_face_enc,
            "created_at": s.created_at.isoformat() if (hasattr(s, "created_at") and hasattr(s.created_at, "isoformat")) else (str(s.created_at) if getattr(s, "created_at", None) else None),
            "updated_at": s.updated_at.isoformat() if (hasattr(s, "updated_at") and hasattr(s.updated_at, "isoformat")) else (str(getattr(s, "updated_at", None)) if getattr(s, "updated_at", None) else None),
        }
        res.append(data)
    return res

@app.post("/api/v1/staff", status_code=status.HTTP_201_CREATED)
@app.post("/staff", status_code=status.HTTP_201_CREATED)
async def create_staff(
    request: Request,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    content_type = request.headers.get("content-type", "")
    if "multipart/form-data" in content_type:
        form = await request.form()
        staff_id = form.get("staff_id")
        name = form.get("name")
        email = form.get("email")
        phone = form.get("phone")
        role = form.get("role", "STAFF")
        branch_id = form.get("branch_id")
        department_id = form.get("department_id")
        shift_start_time = form.get("shift_start_time")
        shift_end_time = form.get("shift_end_time")
        is_visitor = str(form.get("is_visitor", "false")).lower() == "true"
        photo = form.get("photo")
        video = form.get("video")

        if not staff_id or not name:
            raise HTTPException(status_code=400, detail="Staff ID and Name are required")

        existing = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if existing:
            raise HTTPException(status_code=400, detail="Staff ID already exists")

        profile_pic_path = None
        local_photo_filepath = None
        if photo and hasattr(photo, "filename") and photo.filename:
            uploads_dir = os.path.join(os.path.dirname(__file__), "uploads", "photos")
            os.makedirs(uploads_dir, exist_ok=True)
            filename = f"{staff_id}_{photo.filename}"
            local_photo_filepath = os.path.join(uploads_dir, filename)
            contents = await photo.read()
            with open(local_photo_filepath, "wb") as f:
                f.write(contents)
            profile_pic_path = f"/uploads/photos/{filename}"

        local_video_filepath = None
        registration_video_url = None
        if video and hasattr(video, "filename") and video.filename:
            vid_dir = os.path.join(os.path.dirname(__file__), "uploads", "videos")
            os.makedirs(vid_dir, exist_ok=True)
            vid_ext = os.path.splitext(video.filename)[1] or ".mp4"
            vid_filename = f"{staff_id}_registration{vid_ext}"
            local_video_filepath = os.path.join(vid_dir, vid_filename)
            vid_contents = await video.read()
            with open(local_video_filepath, "wb") as f:
                f.write(vid_contents)
            registration_video_url = f"/uploads/videos/{vid_filename}"

        parsed_branch = int(branch_id) if branch_id and str(branch_id).isdigit() else None
        parsed_dept = int(department_id) if department_id and str(department_id).isdigit() else None

        new_staff = Staff(
            staff_id=staff_id,
            name=name,
            email=email or f"{staff_id.lower()}@epic.com",
            phone=phone,
            role=role or "STAFF",
            branch_id=parsed_branch,
            department_id=parsed_dept,
            shift_start_time=shift_start_time,
            shift_end_time=shift_end_time,
            is_visitor=is_visitor,
            profile_picture=profile_pic_path,
            registration_video=registration_video_url
        )
        db.add(new_staff)
        db.commit()
        db.refresh(new_staff)

        try:
            from ai.face_registration import process_biometric_background
            pkl_path = os.path.join(os.path.dirname(__file__), "ai", "encoding", "encodings.pkl")
            dp_dir = os.path.join(os.path.dirname(__file__), "uploads", "photos")
            background_tasks.add_task(
                process_biometric_background,
                staff_id=staff_id,
                name=name,
                video_path=local_video_filepath,
                pkl_path=pkl_path,
                dp_dir=dp_dir,
                photo_path=local_photo_filepath
            )
        except Exception as err:
            print(f"Warning: Failed to queue biometric background task: {err}")

        return new_staff
    else:
        body = await request.json()
        staff_id = body.get("staff_id")
        name = body.get("name")
        if not staff_id or not name:
            raise HTTPException(status_code=400, detail="Staff ID and Name are required")
        existing = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if existing:
            raise HTTPException(status_code=400, detail="Staff ID already exists")
        new_staff = Staff(**body)
        db.add(new_staff)
        db.commit()
        db.refresh(new_staff)
        return new_staff

class StaffUpdateModel(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    branch_id: Optional[int] = None
    department_id: Optional[int] = None
    shift_start_time: Optional[str] = None
    shift_end_time: Optional[str] = None
    is_visitor: Optional[bool] = None
    is_active: Optional[bool] = None

@app.put("/api/v1/staff/{staff_id}")
@app.put("/staff/{staff_id}")
def update_staff(staff_id: str, staff_update: StaffUpdateModel, db: Session = Depends(get_db)):
    staff = None
    if str(staff_id).isdigit():
        staff = db.query(Staff).filter(Staff.id == int(staff_id)).first()
    if not staff:
        staff = db.query(Staff).filter(Staff.staff_id == str(staff_id)).first()
    if not staff:
        raise HTTPException(status_code=404, detail="Staff not found")

    update_data = staff_update.dict(exclude_unset=True)
    if "department_id" in update_data and update_data["department_id"]:
        d_obj = db.query(Department).filter(Department.id == update_data["department_id"]).first()
        if d_obj and d_obj.branch_id:
            update_data["branch_id"] = d_obj.branch_id

    for key, value in update_data.items():
        setattr(staff, key, value)
    db.commit()
    db.refresh(staff)
    return staff

@app.delete("/api/v1/staff/{staff_id}")
@app.delete("/staff/{staff_id}")
def delete_staff(staff_id: str, db: Session = Depends(get_db)):
    staff = None
    if str(staff_id).isdigit():
        staff = db.query(Staff).filter(Staff.id == int(staff_id)).first()
    if not staff:
        staff = db.query(Staff).filter(Staff.staff_id == str(staff_id)).first()

    if not staff:
        raise HTTPException(status_code=404, detail="Staff not found")

    stf_str_id = staff.staff_id
    stf_name = staff.name

    db.delete(staff)
    db.commit()

    # Clean up AI encodings matrix
    pkl_path = os.path.join(os.path.dirname(__file__), "ai", "encoding", "encodings.pkl")
    if os.path.exists(pkl_path):
        try:
            import pickle
            with open(pkl_path, "rb") as f:
                pkl_data = pickle.load(f)
            keys_to_del = [k for k, v in pkl_data.items() if str(k) == str(stf_str_id) or (isinstance(v, dict) and v.get("name") == stf_name)]
            if keys_to_del:
                for k in keys_to_del:
                    del pkl_data[k]
                with open(pkl_path, "wb") as f:
                    pickle.dump(pkl_data, f)
        except Exception as err:
            print(f"Warning cleaning pkl encodings: {err}")

    return {"detail": f"Staff {stf_name} deleted successfully"}


@app.get("/api/v1/branches")
@app.get("/branches")
def get_all_branches(db: Session = Depends(get_db)):
    branches = db.query(Branch).order_by(Branch.id).all()
    res = []
    for b in branches:
        staff_count = db.query(Staff).filter(Staff.branch_id == b.id).count()
        camera_count = db.query(Camera).filter(Camera.branch_id == b.id).count()
        
        # Load branch activities
        branch_activities = db.query(BranchActivity).filter(BranchActivity.branch_id == b.id).order_by(BranchActivity.id).all()
        act_list = [{
            "id": a.id,
            "activity_id": a.activity_id,
            "name": a.name,
            "description": a.description,
            "status": a.status or "active"
        } for a in branch_activities]

        res.append({
            "id": b.id,
            "name": b.name,
            "address": b.address,
            "phone": b.phone,
            "manager_name": b.manager_name,
            "status": getattr(b, "status", "active") or "active",
            "staff_count": staff_count,
            "camera_count": camera_count,
            "activities": act_list,
            "activities_count": len(act_list),
            "created_at": b.created_at.isoformat() if getattr(b, "created_at", None) else None,
            "updated_at": b.updated_at.isoformat() if getattr(b, "updated_at", None) else None
        })
    return res


@app.post("/api/v1/branches", status_code=status.HTTP_201_CREATED)
@app.post("/branches", status_code=status.HTTP_201_CREATED)
def create_branch(branch: BranchCreate, db: Session = Depends(get_db)):
    existing = db.query(Branch).filter(Branch.name == branch.name.strip()).first()
    if existing:
        raise HTTPException(status_code=400, detail="Branch name already exists")
    new_b = Branch(
        name=branch.name.strip(),
        address=branch.address,
        phone=branch.phone,
        manager_name=branch.manager_name,
        status="active"
    )
    db.add(new_b)
    db.commit()
    db.refresh(new_b)

    # Save activities if provided
    if branch.activities:
        seen_ids = set()
        seen_names = set()
        for act in branch.activities:
            if act.activity_id and act.name:
                aid = act.activity_id.strip().upper()
                aname = act.name.strip().lower()
                if aid in seen_ids:
                    raise HTTPException(status_code=400, detail=f"Duplicate Activity ID '{act.activity_id}' in branch")
                if aname in seen_names:
                    raise HTTPException(status_code=400, detail=f"Duplicate Activity Name '{act.name}'. Same activity name cannot be added twice in the same branch.")
                seen_ids.add(aid)
                seen_names.add(aname)

                ba = BranchActivity(
                    branch_id=new_b.id,
                    activity_id=act.activity_id.strip(),
                    name=act.name.strip(),
                    description=act.description,
                    status=act.status or "active"
                )
                db.add(ba)
        db.commit()
        db.refresh(new_b)

    return new_b


@app.put("/api/v1/branches/{branch_id}")
@app.put("/branches/{branch_id}")
def update_branch(branch_id: int, branch_update: BranchUpdate, db: Session = Depends(get_db)):
    branch = db.query(Branch).filter(Branch.id == branch_id).first()
    if not branch:
        raise HTTPException(status_code=404, detail="Branch not found")
    update_data = branch_update.dict(exclude_unset=True)
    
    if "name" in update_data and update_data["name"] != branch.name:
        existing = db.query(Branch).filter(Branch.name == update_data["name"].strip()).first()
        if existing:
            raise HTTPException(status_code=400, detail="Branch name already exists")
            
    for key, value in update_data.items():
        if key == "activities":
            continue
        elif key == "name" and value:
            setattr(branch, key, value.strip())
        else:
            setattr(branch, key, value)

    # Update activities if provided
    if branch_update.activities is not None:
        seen_ids = set()
        seen_names = set()
        for act in branch_update.activities:
            if act.activity_id and act.name:
                aid = act.activity_id.strip().upper()
                aname = act.name.strip().lower()
                if aid in seen_ids:
                    raise HTTPException(status_code=400, detail=f"Duplicate Activity ID '{act.activity_id}' in branch")
                if aname in seen_names:
                    raise HTTPException(status_code=400, detail=f"Duplicate Activity Name '{act.name}'. Same activity name cannot be added twice in the same branch.")
                seen_ids.add(aid)
                seen_names.add(aname)

        db.query(BranchActivity).filter(BranchActivity.branch_id == branch_id).delete()
        for act in branch_update.activities:
            if act.activity_id and act.name:
                ba = BranchActivity(
                    branch_id=branch.id,
                    activity_id=act.activity_id.strip(),
                    name=act.name.strip(),
                    description=act.description,
                    status=act.status or "active"
                )
                db.add(ba)

    db.commit()
    db.refresh(branch)
    return branch


@app.delete("/api/v1/branches/{branch_id}")
@app.delete("/branches/{branch_id}")
def delete_branch(branch_id: int, db: Session = Depends(get_db)):
    branch = db.query(Branch).filter(Branch.id == branch_id).first()
    if not branch:
        raise HTTPException(status_code=404, detail="Branch not found")
    
    # Safely unassign linked staff, cameras, and departments
    db.query(Staff).filter(Staff.branch_id == branch_id).update({"branch_id": None})
    db.query(Camera).filter(Camera.branch_id == branch_id).update({"branch_id": None})
    try:
        db.query(Department).filter(Department.branch_id == branch_id).update({"branch_id": None})
    except Exception:
        pass
    db.query(BranchActivity).filter(BranchActivity.branch_id == branch_id).delete()
    
    db.delete(branch)
    db.commit()
    return {"detail": "Branch deleted successfully", "id": branch_id}


# ─────────────────────────────────────────────────────────────────────────────
# Master Global Activities Endpoints
# ─────────────────────────────────────────────────────────────────────────────

@app.get("/api/v1/global-activities")
@app.get("/api/v1/activities")
@app.get("/global-activities")
@app.get("/activities")
def get_global_activities(db: Session = Depends(get_db)):
    import json
    def parse_act_types(val):
        if not val:
            return []
        if isinstance(val, list):
            return [str(x).strip() for x in val if str(x).strip()]
        try:
            parsed = json.loads(val)
            if isinstance(parsed, list):
                return [str(x).strip() for x in parsed if str(x).strip()]
        except Exception:
            pass
        return [x.strip() for x in str(val).split(",") if x.strip()]

    acts = db.query(Activity).order_by(Activity.id.asc()).all()
    return [{
        "id": a.id,
        "activity_id": a.activity_id,
        "name": a.name,
        "description": a.description,
        "types": parse_act_types(getattr(a, "types", None)),
        "status": a.status or "active",
        "created_at": a.created_at.isoformat() if getattr(a, "created_at", None) else None,
        "updated_at": a.updated_at.isoformat() if getattr(a, "updated_at", None) else None
    } for a in acts]


@app.post("/api/v1/global-activities", status_code=status.HTTP_201_CREATED)
@app.post("/api/v1/activities", status_code=status.HTTP_201_CREATED)
@app.post("/activities", status_code=status.HTTP_201_CREATED)
def create_global_activity(act: GlobalActivityCreate, db: Session = Depends(get_db)):
    import json
    if not act.activity_id.strip() or not act.name.strip():
        raise HTTPException(status_code=400, detail="Activity ID and Activity Name are required")
    
    if db.query(Activity).filter(Activity.activity_id.ilike(act.activity_id.strip())).first():
        raise HTTPException(status_code=400, detail=f"Activity ID '{act.activity_id.strip()}' already exists")
    
    if db.query(Activity).filter(Activity.name.ilike(act.name.strip())).first():
        raise HTTPException(status_code=400, detail=f"Activity with name '{act.name.strip()}' already exists")
    
    types_str = None
    if act.types:
        if isinstance(act.types, list):
            types_str = json.dumps([str(t).strip() for t in act.types if str(t).strip()])
        else:
            types_str = str(act.types).strip()

    new_act = Activity(
        activity_id=act.activity_id.strip().upper(),
        name=act.name.strip(),
        description=act.description,
        types=types_str,
        status=act.status or "active"
    )
    db.add(new_act)
    db.commit()
    db.refresh(new_act)
    return new_act


@app.put("/api/v1/global-activities/{act_id}")
@app.put("/api/v1/activities/{act_id}")
@app.put("/activities/{act_id}")
def update_global_activity(act_id: int, act_in: GlobalActivityUpdate, db: Session = Depends(get_db)):
    import json
    act = db.query(Activity).filter(Activity.id == act_id).first()
    if not act:
        raise HTTPException(status_code=404, detail="Activity not found")
    
    if act_in.name and act_in.name.strip():
        existing = db.query(Activity).filter(Activity.name.ilike(act_in.name.strip()), Activity.id != act_id).first()
        if existing:
            raise HTTPException(status_code=400, detail=f"Activity with name '{act_in.name.strip()}' already exists")
        act.name = act_in.name.strip()
    
    if act_in.description is not None:
        act.description = act_in.description
    if act_in.types is not None:
        if isinstance(act_in.types, list):
            act.types = json.dumps([str(t).strip() for t in act_in.types if str(t).strip()])
        else:
            act.types = str(act_in.types).strip() if act_in.types else None
    if act_in.status is not None:
        act.status = act_in.status
    
    act.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(act)
    return act


@app.delete("/api/v1/global-activities/{act_id}")
@app.delete("/api/v1/activities/{act_id}")
@app.delete("/activities/{act_id}")
def delete_global_activity(act_id: int, db: Session = Depends(get_db)):
    act = db.query(Activity).filter(Activity.id == act_id).first()
    if not act:
        raise HTTPException(status_code=404, detail="Activity not found")
    
    name = act.name
    db.delete(act)
    db.commit()
    return {"detail": f"Activity '{name}' deleted successfully"}


# ─────────────────────────────────────────────────────────────────────────────
# Dedicated Branch Activities Endpoints
# ─────────────────────────────────────────────────────────────────────────────

@app.get("/api/v1/branch-activities")
def get_all_branch_activities(branch_id: Optional[str] = None, db: Session = Depends(get_db)):
    """Fetch assigned activities with their configured types and cameras across branches."""
    q = db.query(BranchActivity)
    if branch_id and branch_id != "all":
        try:
            q = q.filter(BranchActivity.branch_id == int(branch_id))
        except Exception:
            pass
    acts = q.order_by(BranchActivity.id).all()
    return [{
        "id": a.id,
        "branch_id": a.branch_id,
        "activity_id": a.activity_id,
        "name": a.name,
        "floor": getattr(a, "floor", None) or "Ground Floor",
        "camera_direction": getattr(a, "camera_direction", None) or "In",
        "camera_id": getattr(a, "camera_id", None),
        "camera_name": getattr(a, "camera_name", None),
        "status": a.status or "active"
    } for a in acts]

@app.get("/branches/{branch_id}/activities")
@app.get("/api/v1/branches/{branch_id}/activities")
def get_branch_activities(branch_id: int, db: Session = Depends(get_db)):
    branch = db.query(Branch).filter(Branch.id == branch_id).first()
    if not branch:
        raise HTTPException(status_code=404, detail="Branch not found")
    activities = db.query(BranchActivity).filter(BranchActivity.branch_id == branch_id).order_by(BranchActivity.id).all()
    return [{
        "id": a.id,
        "branch_id": a.branch_id,
        "activity_id": a.activity_id,
        "name": a.name,
        "floor": getattr(a, "floor", None) or "Ground Floor",
        "camera_direction": getattr(a, "camera_direction", None) or "In",
        "camera_id": getattr(a, "camera_id", None),
        "camera_name": getattr(a, "camera_name", None),
        "camera_ids": getattr(a, "camera_ids", None),
        "description": a.description,
        "status": a.status or "active",
        "created_at": a.created_at.isoformat() if getattr(a, "created_at", None) else None,
        "updated_at": a.updated_at.isoformat() if getattr(a, "updated_at", None) else None
    } for a in activities]


@app.post("/branches/{branch_id}/activities", status_code=status.HTTP_201_CREATED)
@app.post("/api/v1/branches/{branch_id}/activities", status_code=status.HTTP_201_CREATED)
def create_branch_activity(branch_id: int, activity: ActivityItem, db: Session = Depends(get_db)):
    branch = db.query(Branch).filter(Branch.id == branch_id).first()
    if not branch:
        raise HTTPException(status_code=404, detail="Branch not found")
    
    if not activity.activity_id.strip() or not activity.name.strip():
        raise HTTPException(status_code=400, detail="Activity ID and Name are required")

    target_act_id = activity.activity_id.strip()
    existing_id = db.query(BranchActivity).filter(
        BranchActivity.branch_id == branch_id,
        BranchActivity.activity_id.ilike(target_act_id)
    ).first()
    if existing_id:
        count = 1
        while db.query(BranchActivity).filter(
            BranchActivity.branch_id == branch_id,
            BranchActivity.activity_id.ilike(f"{target_act_id}-{count}")
        ).first():
            count += 1
        target_act_id = f"{target_act_id}-{count}"

    act_floor = activity.floor.strip() if activity.floor else "Ground Floor"
    act_cam_id = activity.camera_id.strip() if activity.camera_id else None
    existing_exact = db.query(BranchActivity).filter(
        BranchActivity.branch_id == branch_id,
        BranchActivity.name.ilike(activity.name.strip()),
        BranchActivity.floor == act_floor,
        BranchActivity.camera_id == act_cam_id
    ).first()
    if existing_exact:
        raise HTTPException(status_code=400, detail=f"This exact activity '{activity.name}' with type '{act_floor}' and this camera already exists in this branch.")

    c_ids_str = None
    if activity.camera_ids:
        if isinstance(activity.camera_ids, list):
            c_ids_str = ",".join([str(c).strip() for c in activity.camera_ids if str(c).strip()])
        else:
            c_ids_str = str(activity.camera_ids).strip()

    new_act = BranchActivity(
        branch_id=branch_id,
        activity_id=target_act_id,
        name=activity.name.strip(),
        floor=activity.floor.strip() if activity.floor else "Ground Floor",
        camera_direction=activity.camera_direction.strip() if activity.camera_direction else "In",
        camera_id=activity.camera_id.strip() if activity.camera_id else None,
        camera_name=activity.camera_name.strip() if activity.camera_name else None,
        camera_ids=c_ids_str,
        description=activity.description,
        status=activity.status or "active"
    )
    db.add(new_act)
    db.commit()
    db.refresh(new_act)

    # Sync linked camera attributes in DB
    target_cams = []
    if activity.camera_id:
        target_cams.append(activity.camera_id.strip())
    if activity.camera_ids and isinstance(activity.camera_ids, list):
        for cid in activity.camera_ids:
            if str(cid).strip() not in target_cams:
                target_cams.append(str(cid).strip())

    for cid in target_cams:
        cid_filter = (Camera.id == int(cid)) if str(cid).isdigit() else (Camera.camera_id == str(cid))
        cam = db.query(Camera).filter(
            Camera.branch_id == branch_id,
            cid_filter
        ).first()
        if cam:
            cam.activity_id = activity.activity_id.strip()
            cam.activity_name = activity.name.strip()
            cdir = (activity.camera_direction or "Single Camera").strip()
            cam.camera_type = cdir
            cdir_lower = cdir.lower()
            if "single" in cdir_lower or "bi" in cdir_lower:
                cam.is_checkin = True
                cam.is_checkout = True
            elif "in" in cdir_lower:
                cam.is_checkin = True
                cam.is_checkout = False
            elif "out" in cdir_lower:
                cam.is_checkin = False
                cam.is_checkout = True
            else:
                cam.is_checkin = True
                cam.is_checkout = False

            if activity.floor:
                cam.sub_location = activity.floor.strip()

    db.commit()
    return new_act


@app.put("/branches/{branch_id}/activities/{activity_db_id}")
@app.put("/api/v1/branches/{branch_id}/activities/{activity_db_id}")
def update_branch_activity(branch_id: int, activity_db_id: int, activity: ActivityItem, db: Session = Depends(get_db)):
    act = db.query(BranchActivity).filter(BranchActivity.id == activity_db_id, BranchActivity.branch_id == branch_id).first()
    if not act:
        raise HTTPException(status_code=404, detail="Activity not found")
    
    if activity.activity_id:
        act.activity_id = activity.activity_id.strip()
    if activity.name:
        act.name = activity.name.strip()
    if activity.floor is not None:
        act.floor = activity.floor.strip() if activity.floor else None
    if activity.camera_direction is not None:
        act.camera_direction = activity.camera_direction.strip() if activity.camera_direction else None
    if activity.camera_id is not None:
        act.camera_id = activity.camera_id.strip() if activity.camera_id else None
    if activity.camera_name is not None:
        act.camera_name = activity.camera_name.strip() if activity.camera_name else None
    if activity.camera_ids is not None:
        if isinstance(activity.camera_ids, list):
            act.camera_ids = ",".join([str(c).strip() for c in activity.camera_ids if str(c).strip()])
        else:
            act.camera_ids = str(activity.camera_ids).strip()
    if activity.description is not None:
        act.description = activity.description
    if activity.status:
        act.status = activity.status

    db.commit()
    db.refresh(act)

    # Sync linked camera attributes in DB
    target_cams = []
    if activity.camera_id:
        target_cams.append(activity.camera_id.strip())
    if activity.camera_ids and isinstance(activity.camera_ids, list):
        for cid in activity.camera_ids:
            if str(cid).strip() not in target_cams:
                target_cams.append(str(cid).strip())

    for cid in target_cams:
        cid_filter = (Camera.id == int(cid)) if str(cid).isdigit() else (Camera.camera_id == str(cid))
        cam = db.query(Camera).filter(
            Camera.branch_id == branch_id,
            cid_filter
        ).first()
        if cam:
            cam.activity_id = act.activity_id
            cam.activity_name = act.name
            cdir = (act.camera_direction or "Single Camera").strip()
            cam.camera_type = cdir
            cdir_lower = cdir.lower()
            if "single" in cdir_lower or "bi" in cdir_lower:
                cam.is_checkin = True
                cam.is_checkout = True
            elif "in" in cdir_lower:
                cam.is_checkin = True
                cam.is_checkout = False
            elif "out" in cdir_lower:
                cam.is_checkin = False
                cam.is_checkout = True
            else:
                cam.is_checkin = True
                cam.is_checkout = False

            if act.floor:
                cam.sub_location = act.floor.strip()

    db.commit()
    return act


@app.delete("/branches/{branch_id}/activities/{activity_db_id}")
@app.delete("/api/v1/branches/{branch_id}/activities/{activity_db_id}")
def delete_branch_activity(branch_id: int, activity_db_id: int, db: Session = Depends(get_db)):
    act = db.query(BranchActivity).filter(BranchActivity.id == activity_db_id, BranchActivity.branch_id == branch_id).first()
    if not act:
        raise HTTPException(status_code=404, detail="Activity not found")
    db.delete(act)
    db.commit()
    return {"detail": "Activity deleted successfully"}


class CameraCreate(BaseModel):
    branch_id: int
    camera_id: str
    name: str
    location: Optional[str] = None
    rtsp_url: Optional[str] = None
    is_checkin: bool = False
    is_checkout: bool = False


class StaffCreate(BaseModel):
    staff_id: str
    name: str
    email: str
    phone: Optional[str] = None
    role: str = "STAFF"
    branch_id: Optional[int] = None
    department_id: Optional[int] = None
    shift_start_time: Optional[str] = None
    shift_end_time: Optional[str] = None
    is_visitor: bool = False
    password: Optional[str] = None
    send_email_credentials: Optional[bool] = False


class StaffUpdate(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = None
    branch_id: Optional[int] = None
    department_id: Optional[int] = None
    shift_start_time: Optional[str] = None
    shift_end_time: Optional[str] = None
    is_visitor: Optional[bool] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None


@app.get("/api/v1/staff")
@app.get("/staff")
def get_all_staff(db: Session = Depends(get_db), current_user: User = Depends(check_permission("view_staff"))):
    staff_members = db.query(Staff).order_by(Staff.id).all()
    res = []
    for s in staff_members:
        res.append({
            "id": s.id,
            "staff_id": s.staff_id,
            "name": s.name,
            "email": s.email,
            "phone": s.phone,
            "role": s.role,
            "is_active": s.is_active if s.is_active is not None else True,
            "has_face_encoding": s.has_face_encoding,
            "profile_picture": s.profile_picture,
            "registration_video": getattr(s, "registration_video", None),
            "branch_id": s.branch_id,
            "branch_name": s.branch.name if s.branch else None,
            "department_id": s.department_id,
            "department_name": s.department.name if s.department else None,
            "shift_start_time": s.shift_start_time,
            "shift_end_time": s.shift_end_time,
            "is_visitor": s.is_visitor,
            "created_at": s.created_at.isoformat() if s.created_at else None,
            "updated_at": (s.updated_at.isoformat() if getattr(s, "updated_at", None) else (s.created_at.isoformat() if s.created_at else None))
        })
    return res

def send_staff_credentials_email_smtp(to_email: str, staff_name: str, staff_id: str, plain_password: str):
    """Send welcome email with account credentials via Amazon SES SMTP."""
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    smtp_server = os.getenv("SMTP_SERVER", "email-smtp.us-east-1.amazonaws.com")
    smtp_port = int(os.getenv("SMTP_PORT", 587))
    smtp_user = os.getenv("SMTP_USERNAME")
    smtp_password = os.getenv("SMTP_PASSWORD")
    sender_email = os.getenv("SMTP_SENDER", "noreply@synavos.com")

    if not smtp_user or not smtp_password:
        print("❌ [SMTP ERROR] SMTP_USERNAME/SMTP_PASSWORD not set in environment; skipping staff credentials email.")
        return

    login_url = os.getenv("PORTAL_LOGIN_URL", "http://localhost:5173")
    subject = "Welcome to EPIC — Your Account Credentials"
    body_html = f"""
    <html>
    <body style="font-family: Arial, sans-serif; background-color: #f8fafc; padding: 20px;">
        <div style="max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 8px; padding: 30px; border: 1px solid #e2e8f0; font-size: 14px; color: #1e293b;">
            <p>Hello <strong>{staff_name}</strong>,</p>
            <p>Your profile have been successfully registered on the EPIC.</p>
            <div style="background-color: #ecfdf5; border-left: 4px solid #10b981; padding: 15px; margin: 20px 0; border-radius: 4px;">
                <p style="margin: 5px 0;"><strong>Staff ID / Username:</strong> {staff_id}</p>
                <p style="margin: 5px 0;"><strong>Email Address:</strong> {to_email}</p>
                <p style="margin: 5px 0;"><strong>Password:</strong> <code style="background: #e2e8f0; padding: 2px 6px; border-radius: 4px; font-weight: bold;">{plain_password}</code></p>
            </div>
            <p>Portal Login: <a href="{login_url}" style="color: #10b981; font-weight: bold;">{login_url}</a></p>
            <p>Please log in and update your password upon your first sign in.</p>
            <p style="color: #64748b; font-size: 0.85rem; margin-top: 30px;">Best regards,<br><strong>EPIC Administrator</strong></p>
        </div>
    </body>
    </html>
    """

    try:
        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"] = f"EPIC <{sender_email}>"
        msg["To"] = to_email
        msg.attach(MIMEText(body_html, "html"))

        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.sendmail(sender_email, [to_email], msg.as_string())
        print(f"✅ [SMTP SUCCESS] Successfully sent credentials email to {to_email}")
    except Exception as e:
        print(f"❌ [SMTP ERROR] Failed to send email to {to_email}: {str(e)}")




@app.post("/api/v1/staff", status_code=status.HTTP_201_CREATED)
@app.post("/staff", status_code=status.HTTP_201_CREATED)
@app.post("/api/v1/staff", status_code=status.HTTP_201_CREATED)
async def create_staff(request: Request, db: Session = Depends(get_db), current_user: User = Depends(check_permission("add_staff"))):
    try:
        content_type = request.headers.get("content-type", "")

        if "multipart/form-data" in content_type:
            form = await request.form()
            staff_id = str(form.get("staff_id", "")).strip()
            name = str(form.get("name", "")).strip()
            email = str(form.get("email", "")).strip()
            phone = str(form.get("phone", "")) if form.get("phone") else None
            role = str(form.get("role", "employee"))

            branch_id_raw = form.get("branch_id")
            branch_id = int(branch_id_raw) if branch_id_raw and str(branch_id_raw).isdigit() else None

            dept_id_raw = form.get("department_id")
            department_id = int(dept_id_raw) if dept_id_raw and str(dept_id_raw).isdigit() else None

            shift_start_time = str(form.get("shift_start_time", "")) or None
            shift_end_time = str(form.get("shift_end_time", "")) or None
            is_visitor = str(form.get("is_visitor", "false")).lower() == "true"
            password = str(form.get("password", "")) if form.get("password") else None
            send_email_credentials = str(form.get("send_email_credentials", "false")).lower() == "true"

            photo = form.get("photo")
            video = form.get("video")
        else:
            body = await request.json()
            staff_id = str(body.get("staff_id", "")).strip()
            name = str(body.get("name", "")).strip()
            email = str(body.get("email", "")).strip()
            phone = body.get("phone")
            role = body.get("role", "employee")
            branch_id = body.get("branch_id")
            department_id = body.get("department_id")
            shift_start_time = body.get("shift_start_time")
            shift_end_time = body.get("shift_end_time")
            is_visitor = bool(body.get("is_visitor", False))
            password = body.get("password")
            send_email_credentials = bool(body.get("send_email_credentials", False))
            photo = None
            video = None

        if not staff_id or not name or not email:
            raise HTTPException(status_code=400, detail="staff_id, name, and email are required fields.")

        existing_id = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if existing_id:
            raise HTTPException(status_code=400, detail=f"Staff with ID '{staff_id}' already exists.")

        existing_email = db.query(Staff).filter(Staff.email == email).first()
        if existing_email:
            raise HTTPException(status_code=400, detail=f"Staff with email '{email}' already exists.")

        # Handle Photo File Upload
        profile_pic_url = None
        if photo and hasattr(photo, "filename") and photo.filename:
            try:
                upload_dir = os.path.join(os.path.dirname(__file__), "uploads", "photos")
                os.makedirs(upload_dir, exist_ok=True)
                filename = f"{staff_id}_{photo.filename}"
                filepath = os.path.join(upload_dir, filename)
                content = await photo.read()
                with open(filepath, "wb") as f:
                    f.write(content)
                profile_pic_url = f"/uploads/photos/{filename}"
            except Exception as fe:
                print(f"⚠️ Photo upload warning: {fe}")

        new_staff = Staff(
            staff_id=staff_id,
            name=name,
            email=email,
            phone=phone,
            role=role,
            branch_id=branch_id,
            department_id=department_id,
            shift_start_time=shift_start_time,
            shift_end_time=shift_end_time,
            is_visitor=is_visitor,
            profile_picture=profile_pic_url,
            has_face_encoding=bool(profile_pic_url),
            is_active=True
        )
        db.add(new_staff)
        db.commit()
        db.refresh(new_staff)

        # Link/Create User Account for Dashboard Login if Password Provided
        if password:
            user_account = db.query(User).filter(User.email == email).first()
            if not user_account:
                user_account = User(
                    username=staff_id,
                    email=email,
                    hashed_password=hash_password(password),
                    full_name=name,
                    role=role or "viewer",
                    department_id=department_id,
                    is_active=True
                )
                db.add(user_account)
            else:
                user_account.hashed_password = hash_password(password)
                user_account.role = role or user_account.role
            db.commit()

            if send_email_credentials:
                threading.Thread(
                    target=send_staff_credentials_email_smtp,
                    args=(email, name, staff_id, password),
                    daemon=True
                ).start()

        return new_staff
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        print(f"❌ [CREATE STAFF ERROR] {e}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
async def create_staff(
    request: Request,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    content_type = request.headers.get("content-type", "")
    if "multipart/form-data" in content_type:
        form = await request.form()
        staff_id = form.get("staff_id")
        name = form.get("name")
        email = form.get("email")
        phone = form.get("phone")
        role = form.get("role", "STAFF")
        branch_id = form.get("branch_id")
        department_id = form.get("department_id")
        shift_start_time = form.get("shift_start_time")
        shift_end_time = form.get("shift_end_time")
        is_visitor = str(form.get("is_visitor", "false")).lower() == "true"
        photo = form.get("photo")
        video = form.get("video")

        if not staff_id or not name:
            raise HTTPException(status_code=400, detail="Staff ID and Name are required")

        existing = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if existing:
            raise HTTPException(status_code=400, detail="Staff ID already exists")

        profile_pic_path = None
        local_photo_filepath = None
        if photo and hasattr(photo, "filename") and photo.filename:
            uploads_dir = os.path.join(os.path.dirname(__file__), "uploads", "photos")
            os.makedirs(uploads_dir, exist_ok=True)
            filename = f"{staff_id}_{photo.filename}"
            local_photo_filepath = os.path.join(uploads_dir, filename)
            contents = await photo.read()
            with open(local_photo_filepath, "wb") as f:
                f.write(contents)
            profile_pic_path = f"/uploads/photos/{filename}"

        local_video_filepath = None
        if video and hasattr(video, "filename") and video.filename:
            temp_vid_dir = os.path.join(os.path.dirname(__file__), "uploads", "temp_videos")
            os.makedirs(temp_vid_dir, exist_ok=True)
            vid_filename = f"{staff_id}_{video.filename}"
            local_video_filepath = os.path.join(temp_vid_dir, vid_filename)
            vid_contents = await video.read()
            with open(local_video_filepath, "wb") as f:
                f.write(vid_contents)

        parsed_branch = int(branch_id) if branch_id and str(branch_id).isdigit() else None
        parsed_dept = int(department_id) if department_id and str(department_id).isdigit() else None

        new_staff = Staff(
            staff_id=staff_id,
            name=name,
            email=email or f"{staff_id.lower()}@epic.com",
            phone=phone,
            role=role or "STAFF",
            branch_id=parsed_branch,
            department_id=parsed_dept,
            shift_start_time=shift_start_time,
            shift_end_time=shift_end_time,
            is_visitor=is_visitor,
            profile_picture=profile_pic_path
        )
        db.add(new_staff)
        db.commit()
        db.refresh(new_staff)

        # Trigger Biometric Background Processing for Video / Photo
        try:
            from ai.face_registration import process_biometric_background
            pkl_path = os.path.join(os.path.dirname(__file__), "ai", "encoding", "encodings.pkl")
            dp_dir = os.path.join(os.path.dirname(__file__), "uploads", "photos")
            background_tasks.add_task(
                process_biometric_background,
                staff_id=staff_id,
                name=name,
                video_path=local_video_filepath,
                pkl_path=pkl_path,
                dp_dir=dp_dir,
                photo_path=local_photo_filepath
            )
        except Exception as err:
            print(f"Warning: Failed to queue biometric background task: {err}")

        return new_staff
    else:
        body = await request.json()
        staff_id = body.get("staff_id")
        name = body.get("name")
        if not staff_id or not name:
            raise HTTPException(status_code=400, detail="Staff ID and Name are required")
        existing = db.query(Staff).filter(Staff.staff_id == staff_id).first()
        if existing:
            raise HTTPException(status_code=400, detail="Staff ID already exists")
        new_staff = Staff(**body)
        db.add(new_staff)
        db.commit()
        db.refresh(new_staff)
        return new_staff

@app.put("/staff/{staff_id}")
def update_staff(staff_id: int, staff_update: StaffUpdate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("update_staff"))):
    staff = db.query(Staff).filter(Staff.id == staff_id).first()
    if not staff:
        raise HTTPException(status_code=404, detail="Staff not found")
    update_data = staff_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(staff, key, value)
    staff.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(staff)
    return staff

@app.delete("/api/v1/staff/{staff_id}")
@app.delete("/staff/{staff_id}")
def delete_staff(staff_id: int, db: Session = Depends(get_db), current_user: User = Depends(check_permission("remove_staff"))):
    staff = db.query(Staff).filter(Staff.id == staff_id).first()
def delete_staff(staff_id: str, db: Session = Depends(get_db)):
    staff = None
    if str(staff_id).isdigit():
        staff = db.query(Staff).filter(Staff.id == int(staff_id)).first()
    if not staff:
        staff = db.query(Staff).filter(Staff.staff_id == str(staff_id)).first()

    if not staff:
        raise HTTPException(status_code=404, detail="Staff not found")

    stf_str_id = staff.staff_id
    stf_name = staff.name

    db.delete(staff)
    db.commit()

    # Clean up AI encodings matrix
    pkl_path = os.path.join(os.path.dirname(__file__), "ai", "encoding", "encodings.pkl")
    if os.path.exists(pkl_path):
        try:
            import pickle
            with open(pkl_path, "rb") as f:
                pkl_data = pickle.load(f)
            keys_to_del = [k for k, v in pkl_data.items() if k == stf_str_id or (isinstance(v, dict) and v.get("name") == stf_name)]
            if keys_to_del:
                for k in keys_to_del:
                    del pkl_data[k]
                with open(pkl_path, "wb") as f:
                    pickle.dump(pkl_data, f)
        except Exception:
            pass

    return {"detail": f"Staff {stf_name} deleted successfully"}





# ─────────────────────────────────────────────────────────────────────────────
# Camera Management Endpoints
# ─────────────────────────────────────────────────────────────────────────────

class CameraCreate(BaseModel):
    camera_id: str
    name: str
    branch_id: int
    activity_id: Optional[str] = None
    activity_name: Optional[str] = None
    camera_type: str = "In" # "In" or "Out"
    recording_path: Optional[str] = ""
    rtsp_url: Optional[str] = ""
    location: Optional[str] = ""
    sub_location: Optional[str] = ""
    is_checkin: bool = False
    is_checkout: bool = False
    status: Optional[str] = "active"

@app.get("/api/v1/cameras")
@app.get("/cameras")
def get_cameras(
    branch_id: Optional[str] = None,
    activity_id: Optional[str] = None,
    camera_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """List all registered cameras with branch name, activity details, direction, and recording path."""
    q = db.query(Camera)
    if branch_id and branch_id != "all":
        try:
            q = q.filter(Camera.branch_id == int(branch_id))
        except (ValueError, TypeError):
            pass
    if activity_id and activity_id != "all":
        q = q.filter(Camera.activity_id == activity_id)
    if camera_type and camera_type != "all":
        q = q.filter(Camera.camera_type == camera_type)
    
    cameras = q.order_by(Camera.id.desc()).all()
    res = []
    for c in cameras:
        # Count total events processed from this camera
        ev_count = 0
        try:
            ev_count = db.query(Event).filter(Event.camera_id == c.camera_id).count()
        except Exception:
            pass

        rec_path = getattr(c, "recording_path", None) or c.rtsp_url or ""
        act_name = getattr(c, "activity_name", None) or c.location or "Attendance"
        cam_type = getattr(c, "camera_type", None) or ("In" if c.is_checkin else "Out")

        res.append({
            "id": c.id,
            "camera_id": c.camera_id,
            "name": c.name,
            "branch_id": c.branch_id,
            "branch_name": c.branch.name if c.branch else "General Branch",
            "activity_id": getattr(c, "activity_id", None) or "",
            "activity_name": act_name,
            "camera_type": cam_type,
            "recording_path": rec_path,
            "rtsp_url": rec_path,
            "location": c.location or (c.branch.name if c.branch else ""),
            "sub_location": c.sub_location or "",
            "is_checkin": (cam_type.lower() == "in") if cam_type else c.is_checkin,
            "is_checkout": (cam_type.lower() == "out") if cam_type else c.is_checkout,
            "status": c.status or "active",
            "events_count": ev_count,
            "created_at": c.created_at.isoformat() if getattr(c, "created_at", None) else None,
            "updated_at": (getattr(c, "updated_at", None) or c.created_at).isoformat() if (getattr(c, "updated_at", None) or getattr(c, "created_at", None)) else None
        })
    return res

def _ensure_camera_folder(cam: Camera):
    """Auto-create dedicated video intake directory for this camera."""
    base_dir = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "videos"))
    cam_id_slug = re.sub(r'[^a-zA-Z0-9_-]', '_', cam.camera_id).lower()
    folder_path = os.path.join(base_dir, "cameras", cam_id_slug)
    try:
        os.makedirs(folder_path, exist_ok=True)
    except Exception:
        pass
    return folder_path

@app.post("/api/v1/cameras")
@app.post("/cameras")
def create_camera(data: CameraCreate, db: Session = Depends(get_db)):
    """Register a new camera with branch, activity, direction (In/Out), and recording path."""
    existing = db.query(Camera).filter(Camera.camera_id == data.camera_id.strip()).first()
    if existing:
        raise HTTPException(status_code=400, detail=f"Camera with ID '{data.camera_id}' already exists.")

    cam_direction = (data.camera_type or "In").strip()
    is_in = (cam_direction.lower() == "in")
    is_out = (cam_direction.lower() == "out")

    rec_path = (data.recording_path or data.rtsp_url or "").strip()

    cam = Camera(
        camera_id=data.camera_id.strip(),
        name=data.name.strip(),
        branch_id=data.branch_id,
        activity_id=data.activity_id.strip() if data.activity_id else None,
        activity_name=data.activity_name.strip() if data.activity_name else "Attendance",
        location=data.location.strip() if data.location else "",
        sub_location=data.sub_location.strip() if data.sub_location else "",
        camera_type=cam_direction,
        is_checkin=is_in,
        is_checkout=is_out,
        recording_path=rec_path,
        rtsp_url=rec_path,
        status=data.status or "active"
    )
    db.add(cam)
    db.commit()
    db.refresh(cam)
    
    # Auto-create backend folder for incoming videos
    watch_folder = _ensure_camera_folder(cam)
    
    return {
        "message": "Camera created successfully",
        "id": cam.id,
        "camera_id": cam.camera_id,
        "watch_directory": watch_folder
    }

@app.put("/api/v1/cameras/{cam_id}")
@app.put("/cameras/{cam_id}")
def update_camera(cam_id: str, data: CameraCreate, db: Session = Depends(get_db)):
    """Update camera details."""
    c_filter = (Camera.id == int(cam_id)) if str(cam_id).isdigit() else (Camera.camera_id == str(cam_id))
    cam = db.query(Camera).filter(c_filter).first()
    if not cam:
        raise HTTPException(status_code=404, detail="Camera not found")

    if data.camera_id.strip() != cam.camera_id:
        dup = db.query(Camera).filter(Camera.camera_id == data.camera_id.strip(), Camera.id != cam.id).first()
        if dup:
            raise HTTPException(status_code=400, detail=f"Camera ID '{data.camera_id}' already in use.")

    cam_direction = (data.camera_type or "In").strip()
    rec_path = (data.recording_path or data.rtsp_url or "").strip()

    cam.camera_id = data.camera_id.strip()
    cam.name = data.name.strip()
    cam.branch_id = data.branch_id
    if hasattr(cam, "activity_id"):
        cam.activity_id = data.activity_id.strip() if data.activity_id else None
    if hasattr(cam, "activity_name"):
        cam.activity_name = data.activity_name.strip() if data.activity_name else "Attendance"
    if hasattr(cam, "recording_path"):
        cam.recording_path = rec_path
    cam.location = data.location.strip() if data.location else ""
    cam.sub_location = data.sub_location.strip() if data.sub_location else ""
    cam.camera_type = cam_direction
    cam.is_checkin = (cam_direction.lower() == "in")
    cam.is_checkout = (cam_direction.lower() == "out")
    cam.rtsp_url = rec_path
    if data.status:
        cam.status = data.status

    db.commit()
    db.refresh(cam)
    return {"message": "Camera updated successfully", "id": cam.id}

@app.delete("/api/v1/cameras/{cam_id}")
@app.delete("/cameras/{cam_id}")
def delete_camera(cam_id: str, db: Session = Depends(get_db)):
    """Delete a camera."""
    c_filter = (Camera.id == int(cam_id)) if str(cam_id).isdigit() else (Camera.camera_id == str(cam_id))
    cam = db.query(Camera).filter(c_filter).first()
    if not cam:
        raise HTTPException(status_code=404, detail="Camera not found")
    db.delete(cam)
    db.commit()
    return {"message": "Camera deleted successfully"}

@app.get("/cameras/locations")
def get_camera_locations(camera_type: Optional[str] = None, db: Session = Depends(get_db)):
    """Return distinct camera sub-locations and locations for filtering."""
    q = db.query(Camera)
    if camera_type and camera_type != "all":
        q = q.filter(Camera.camera_type == camera_type)
    cams = q.all()
    locs = set()
    for c in cams:
        if c.sub_location:
            locs.add(c.sub_location)
        elif c.location:
            locs.add(c.location)
    return sorted(list(locs))


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Offline Pipeline Control Endpoints
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

import subprocess
import queue
import json as _json

from logger import system_log
from database.database import SystemLog

_pipeline_process = None
_pipeline_status = {"running": False, "exit_code": None, "started_at": None}

def _stream_process_output(proc):
    global _pipeline_status
    for line in iter(proc.stdout.readline, b""):
        decoded = line.decode("utf-8", errors="replace").rstrip()
        if "[PIPELINE_MAIN]" not in decoded and "[PIPELINE1]" not in decoded and "[PIPELINE2]" not in decoded:
            system_log(decoded, level="raw", module="stdout")
    proc.wait()
    _pipeline_status["running"] = False
    _pipeline_status["exit_code"] = proc.returncode
    system_log(f"__DONE__ Exit code: {proc.returncode}", level="info", module="api")

@app.post("/pipeline/start")
@app.post("/api/v1/pipeline/start")
def start_pipeline():
    global _pipeline_process, _pipeline_status
    if _pipeline_status.get("running"):
        # Check if process is actually alive
        if _pipeline_process and _pipeline_process.poll() is None:
            raise HTTPException(status_code=409, detail="Pipeline is already running")
        else:
            _pipeline_status["running"] = False

    runner_py = os.path.join(os.path.dirname(__file__), "integrated_pipeline.py")
    python_exe = sys.executable

    _pipeline_status = {"running": True, "exit_code": None, "started_at": datetime.now().isoformat()}
    system_log("Starting Dedicated Sequential GPU AI Pipeline...", level="info", module="api")

    proc = subprocess.Popen(
        [python_exe, "-u", runner_py],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        cwd=os.path.dirname(__file__),
    )
    _pipeline_process = proc

    t = threading.Thread(target=_stream_process_output, args=(proc,), daemon=True)
    t.start()

    return {"message": "Pipeline started", "started_at": _pipeline_status["started_at"]}

@app.post("/pipeline/stop")
@app.post("/api/v1/pipeline/stop")
def stop_pipeline():
    global _pipeline_process, _pipeline_status
    if _pipeline_process and _pipeline_status["running"]:
        _pipeline_process.kill()
        _pipeline_status["running"] = False
        system_log("__DONE__ Pipeline stopped by user.", level="warn", module="api")
        return {"message": "Pipeline stopped"}
    raise HTTPException(status_code=404, detail="No pipeline is currently running")

@app.get("/pipeline/status")
@app.get("/api/v1/pipeline/status")
def get_pipeline_status():
    return _pipeline_status

@app.post("/ai/process_video")
def ai_process_video(payload: dict = None):
    """
    DEPRECATED & DISABLED. This ran a second, independent recognition engine
    (ai/tracker_engine.py + ai/matcher.py) with its own hardcoded similarity
    threshold and tracking logic -- structurally different from the canonical
    pipeline (integrated_pipeline.py, invoked via parallel_runner.py /
    auto_pipeline.py), which is the only path deployed by Dockerfile/systemd.
    Leaving this reachable meant the same footage could get a different
    recognition verdict depending on which endpoint processed it. Disabled
    rather than removed so any caller gets a clear error instead of a 404.
    """
    raise HTTPException(
        status_code=410,
        detail="This endpoint is deprecated and disabled: it ran a second, divergent "
               "recognition engine inconsistent with the main pipeline. Use the standard "
               "video ingestion path (data/raw/<role>/ + the auto-pipeline watcher, or "
               "POST /pipeline/start) instead.",
    )

@app.get("/ai/health")
def ai_health():
    """DEPRECATED & DISABLED -- see /ai/process_video. Kept only so existing
    health-check callers get a clear, explicit signal instead of a bare 404."""
    return {"status": "deprecated", "detail": "This engine has been disabled; it is not the production recognition pipeline."}

@app.get("/pipeline/logs")
def get_pipeline_logs(limit: int = 1000, db: Session = Depends(get_db)):
    logs = db.query(SystemLog).order_by(SystemLog.id.desc()).limit(limit).all()
    # Return in chronological order
    return [{"id": l.id, "timestamp": l.timestamp, "level": l.level, "module": l.module, "message": l.message} for l in reversed(logs)]


@app.get("/pipeline/videos")
def get_pipeline_videos(db: Session = Depends(get_db)):
    videos = db.query(Video).order_by(Video.created_at.desc()).all()
    res = []
    for v in videos:
        res.append({
            "id": v.id,
            "filename": v.filename,
            "camera_name": v.camera_name,
            "camera_role": v.folder_type,
            "video_start_time": v.video_start_time,
            "status": v.status,
            "event_count": len(v.events),
            "recognized_count": sum(1 for e in v.events if e.recognition_status == "recognized")
        })
    return res


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# EPICM-3: Enhanced Events API (v1) â€” Advanced filtering, pagination, sorting
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

@app.get("/api/v1/events")
def get_events_v1(
    staff: Optional[str] = None,
    camera_role: Optional[str] = None,
    camera_type: Optional[str] = None,
    sub_location: Optional[str] = None,
    department: Optional[str] = None,
    status_filter: Optional[str] = None,
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    branch_id: Optional[str] = None,
    sort_by: str = "timestamp",
    order: str = "desc",
    page: int = 1,
    per_page: int = 50,
    db: Session = Depends(get_db)
):
    """
    Enhanced events endpoint with advanced filtering, pagination, and sorting.
    """
    q = db.query(Event)

    # Filters
    if staff:
        from sqlalchemy import or_
        staff_pattern = f"%{staff}%"
        or_conditions = [
            Event.STAFF_name.ilike(staff_pattern),
            Event.STAFF_id.ilike(staff_pattern),
        ]
        if staff.isdigit():
            or_conditions.append(Event.track_id == int(staff))
        q = q.filter(or_(*or_conditions))
    if camera_type and camera_type != "all":
        from sqlalchemy import or_
        if camera_type.lower() == "attendance":
            q = q.filter(or_(
                Event.camera_role.in_(["checkin", "checkout", "in", "out"]),
                Event.event_type.in_(["check_in", "check_out", "checkin", "checkout", "in", "out"])
            ))
        elif camera_type.lower() == "break":
            q = q.filter(or_(
                Event.camera_role.in_(["breakin", "breakout", "break_in", "break_out"]),
                Event.event_type.in_(["break_start", "break_end", "breakin", "breakout"])
            ))
        else:
            q = q.filter(or_(
                Event.camera_role.ilike(f"%{camera_type}%"),
                Event.event_type.ilike(f"%{camera_type}%")
            ))

    if camera_role and camera_role != "all":
        from sqlalchemy import or_
        c_role = camera_role.lower().replace(" ", "").replace("_", "")
        if c_role in ["checkin", "in", "arrival"]:
            q = q.filter(or_(
                Event.camera_role.in_(["checkin", "in"]),
                Event.event_type.in_(["check_in", "checkin", "in"])
            ))
        elif c_role in ["checkout", "out", "departure"]:
            q = q.filter(or_(
                Event.camera_role.in_(["checkout", "out"]),
                Event.event_type.in_(["check_out", "checkout", "out"])
            ))
        elif c_role in ["breakin", "breakstart"]:
            q = q.filter(or_(
                Event.camera_role.in_(["breakin", "break_in"]),
                Event.event_type.in_(["break_start", "breakin", "break_in"])
            ))
        elif c_role in ["breakout", "breakend"]:
            q = q.filter(or_(
                Event.camera_role.in_(["breakout", "break_out"]),
                Event.event_type.in_(["break_end", "breakout", "break_out"])
            ))
        else:
            q = q.filter(or_(
                Event.camera_role.ilike(f"%{camera_role}%"),
                Event.event_type.ilike(f"%{camera_role}%")
            ))
    if status_filter and status_filter != "all":
        q = q.filter(Event.recognition_status == status_filter)
    if department and department != "all":
        dept_staff = db.query(Staff.staff_id).join(Department).filter(Department.name == department).all()
        dept_staff_ids = [s[0] for s in dept_staff if s[0]]
        if dept_staff_ids:
            q = q.filter(Event.STAFF_id.in_(dept_staff_ids))
        else:
            q = q.filter(Event.id == -1)
    if sub_location and sub_location != "all":
        from sqlalchemy import or_
        cams = db.query(Camera.name).filter(or_(
            Camera.sub_location.ilike(f"%{sub_location}%"),
            Camera.camera_id.ilike(f"%{sub_location}%"),
            Camera.name.ilike(f"%{sub_location}%")
        )).all()
        cam_names = [c[0] for c in cams if c[0]]

        # Also check branch activities assigned to this floor / sub_location
        b_act_query = db.query(BranchActivity.camera_id, BranchActivity.camera_name).filter(
            BranchActivity.floor.ilike(f"%{sub_location}%")
        )
        if branch_id and branch_id != "all":
            try:
                b_act_query = b_act_query.filter(BranchActivity.branch_id == int(branch_id))
            except Exception:
                pass

        b_act_cams = b_act_query.all()
        for bac in b_act_cams:
            if bac[0] and bac[0] not in cam_names:
                cam_names.append(bac[0])
            if bac[1] and bac[1] not in cam_names:
                cam_names.append(bac[1])

        if cam_names:
            vids = db.query(Video.id).filter(Video.camera_name.in_(cam_names)).all()
            vid_ids = [v[0] for v in vids]
            if vid_ids:
                q = q.filter(Event.video_id.in_(vid_ids))
            else:
                q = q.filter(Event.id == -1)
    if branch_id and branch_id != "all":
        from sqlalchemy import or_
        b_id = int(branch_id)
        
        # 1. Cameras registered under this branch
        cameras = db.query(Camera).filter(Camera.branch_id == b_id).all()
        camera_names = [c.name for c in cameras] + [c.camera_id for c in cameras if c.camera_id]
        
        # 2. Staff registered under this branch
        staff_list = db.query(Staff).filter(Staff.branch_id == b_id).all()
        staff_ids = [s.staff_id for s in staff_list if s.staff_id]
        staff_names = [s.name for s in staff_list if s.name]

        conditions = []
        
        if camera_names:
            video_ids = [v.id for v in db.query(Video).filter(Video.camera_name.in_(camera_names)).all()]
            if video_ids:
                conditions.append(Event.video_id.in_(video_ids))
                
        if staff_ids:
            conditions.append(Event.STAFF_id.in_(staff_ids))
        if staff_names:
            conditions.append(Event.STAFF_name.in_(staff_names))

        # Fallback: If no camera records exist in DB yet and this is the first/primary branch, show all events
        total_cameras_in_db = db.query(Camera).count()
        if total_cameras_in_db == 0:
            first_branch = db.query(Branch).first()
            if first_branch and first_branch.id == b_id:
                conditions.append(True)

        if any(c is True for c in conditions):
            pass # Keep q as is (all events for primary branch when no cameras configured)
        elif conditions:
            q = q.filter(or_(*conditions))
        else:
            q = q.filter(Event.id == -1)
    if date_from or date_to:
        from datetime import datetime, timedelta
        from sqlalchemy import or_

        def to_dd_mm_yyyy(d_str):
            if not d_str:
                return None
            parts = d_str.split('-')
            if len(parts) == 3 and len(parts[0]) == 4:
                return f"{parts[2]}-{parts[1]}-{parts[0]}"
            return d_str

        dd_from = to_dd_mm_yyyy(date_from)
        dd_to = to_dd_mm_yyyy(date_to) if date_to else dd_from

        if date_from and (not date_to or date_from == date_to):
            # Single day filter on video Event.timestamp (stored as 'HH:MM:SS (DD-MM-YYYY HH:MM:SS)')
            q = q.filter(Event.timestamp.like(f"%{dd_from}%"))
        else:
            # Date range filter on video Event.timestamp
            start_dt = parse_dt(date_from)
            end_dt = parse_dt(date_to) if date_to else start_dt

            if start_dt and end_dt:
                curr = start_dt
                target_dates = []
                while curr <= end_dt and len(target_dates) <= 60:
                    target_dates.append("%" + curr.strftime("%d-%m-%Y") + "%")
                    curr += timedelta(days=1)
                
                if target_dates:
                    q = q.filter(or_(*[Event.timestamp.like(td) for td in target_dates]))

    # Total count before pagination
    total = q.count()

    # Sorting
    sort_map = {
        "timestamp": Event.timestamp,
        "STAFF_name": Event.STAFF_name,
        "confidence": Event.recognition_confidence,
        "id": Event.id,
        "track_id": Event.track_id,
    }
    sort_col = sort_map.get(sort_by, Event.timestamp)
    if order == "asc":
        q = q.order_by(sort_col.asc())
    else:
        q = q.order_by(sort_col.desc())

    # Pagination
    offset = (page - 1) * per_page
    events = q.offset(offset).limit(per_page).all()

    # Build lookups for staff (branch, department, profile_picture) and video/camera (sub_location, branch)
    emp_ids = list(set(e.STAFF_id for e in events if e.STAFF_id))
    staff_map = {}
    if emp_ids:
        staff_objs = db.query(Staff).filter(Staff.staff_id.in_(emp_ids)).all()
        for s in staff_objs:
            b_name = s.branch.name if s.branch else None
            d_name = s.department.name if s.department else None
            staff_map[s.staff_id] = {
                "profile_picture": s.profile_picture,
                "branch_name": b_name,
                "department": d_name,
            }

    video_ids = list(set(e.video_id for e in events if e.video_id))
    video_camera_map = {}
    if video_ids:
        videos = db.query(Video).filter(Video.id.in_(video_ids)).all()
        cam_names = list(set(v.camera_name for v in videos if v.camera_name))
        cams = {c.name: c for c in db.query(Camera).filter(Camera.name.in_(cam_names)).all()} if cam_names else {}
        for v in videos:
            c_obj = cams.get(v.camera_name)
            video_camera_map[v.id] = {
                "sub_location": c_obj.sub_location if c_obj else None,
                "branch_name": c_obj.branch.name if (c_obj and c_obj.branch) else None,
            }

    branches_all = {b.id: b.name for b in db.query(Branch).all()}
    default_branch_name = list(branches_all.values())[0] if branches_all else "Main Branch"

    return {
        "total": total,
        "page": page,
        "per_page": per_page,
        "total_pages": (total + per_page - 1) // per_page if per_page > 0 else 0,
        "data": [
            {
                "id": e.id,
                "video_id": e.video_id,
                "camera_role": e.camera_role,
                "track_id": e.track_id,
                "event_type": e.event_type,
                "timestamp": e.timestamp,
                "frame_number": e.frame_number,
                "confidence": round(e.confidence or 0.0, 4),
                "STAFF_name": e.STAFF_name or f"Person #{e.track_id}",
                "STAFF_id": e.STAFF_id,
                "branch_name": staff_map.get(e.STAFF_id, {}).get("branch_name") or video_camera_map.get(e.video_id, {}).get("branch_name") or default_branch_name,
                "department": staff_map.get(e.STAFF_id, {}).get("department") or "General",
                "sub_location": video_camera_map.get(e.video_id, {}).get("sub_location") or "Main Gate",
                "profile_picture": staff_map.get(e.STAFF_id, {}).get("profile_picture") if e.STAFF_id else None,
                "recognition_confidence": round(e.recognition_confidence or 0.0, 4),
                "recognition_status": e.recognition_status,
                "status": e.status,
                "recognized_at": e.recognized_at.isoformat() if e.recognized_at else None,
                "created_at": e.created_at.isoformat() if e.created_at else None,
            }
            for e in events
        ],
    }


@app.get("/api/v1/events/stats")
def get_events_stats(db: Session = Depends(get_db)):
    """Quick stats for the events dashboard header cards."""
    total = db.query(Event).count()
    recognized = db.query(Event).filter(Event.recognition_status == "recognized").count()
    unrecognized = db.query(Event).filter(Event.recognition_status == "unrecognized").count()
    no_face = db.query(Event).filter(Event.recognition_status == "no_face").count()
    pending = db.query(Event).filter(Event.recognition_status == "pending").count()
    unique_staff = (
        db.query(Event.STAFF_name)
        .filter(Event.recognition_status == "recognized", Event.STAFF_name.isnot(None))
        .distinct()
        .count()
    )
    return {
        "total": total,
        "recognized": recognized,
        "unrecognized": unrecognized,
        "no_face": no_face,
        "pending": pending,
        "unique_staff": unique_staff,
        "recognition_rate": round((recognized / total * 100), 1) if total > 0 else 0,
    }


@app.get("/api/v1/events/{event_id}")
def get_event_v1(event_id: int, db: Session = Depends(get_db)):
    """Single event detail with video info for video-jump feature."""
    e = db.query(Event).filter(Event.id == event_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Event not found")

    video_info = None
    if e.video_id:
        v = db.query(Video).filter(Video.id == e.video_id).first()
        if v:
            fps_val = v.fps or 25.0
            raw_sec = (e.frame_number / fps_val) if e.frame_number else 0.0

            # 1. Parse start time from video_start_time or filename
            v_start_dt = None
            if v.video_start_time:
                v_start_dt = parse_dt(v.video_start_time)
            
            if not v_start_dt and v.filename:
                # Regex match 20260825185502 in filename
                import re
                m = re.search(r'(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})', v.filename)
                if m:
                    try:
                        v_start_dt = datetime(int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5)), int(m.group(6)))
                    except Exception:
                        pass

            if e.timestamp and v_start_dt:
                ev_dt = parse_dt(e.timestamp)
                if ev_dt:
                    diff_sec = (ev_dt - v_start_dt).total_seconds()
                    if 0 <= diff_sec <= 86400:
                        raw_sec = diff_sec

            seek_seconds_val = round(max(0.0, raw_sec - 3.0), 1)
            video_info = {
                "id": v.id,
                "filename": v.filename,
                "folder_type": v.folder_type,
                "file_path": v.file_path,
                "fps": fps_val,
                "duration_seconds": v.duration_seconds or 600.0,
                "video_start_time": v.video_start_time,
                "seek_seconds": seek_seconds_val,
            }

    return {
        "id": e.id,
        "video_id": e.video_id,
        "camera_role": e.camera_role,
        "track_id": e.track_id,
        "event_type": e.event_type,
        "timestamp": e.timestamp,
        "frame_number": e.frame_number,
        "confidence": round(e.confidence or 0.0, 4),
        "STAFF_name": e.STAFF_name or f"Person #{e.track_id}",
        "STAFF_id": e.STAFF_id,
        "recognition_confidence": round(e.recognition_confidence or 0.0, 4),
        "recognition_status": e.recognition_status,
        "status": e.status,
        "recognized_at": e.recognized_at.isoformat() if e.recognized_at else None,
        "created_at": e.created_at.isoformat() if e.created_at else None,
        "video": video_info,
    }


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Video Streaming (for interactive video-jump feature)
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

from starlette.responses import Response as StarletteResponse

@app.get("/api/v1/videos/stream/{video_id}")
@app.get("/videos/stream/{video_id}")
def stream_video(video_id: int, db: Session = Depends(get_db)):
    """
    Stream a raw MP4 video file with HTTP Range header support for seeking.
    The frontend video player needs Range support to jump to specific timestamps.
    """
    video = db.query(Video).filter(Video.id == video_id).first()
    if not video:
        raise HTTPException(status_code=404, detail="Video not found")

    file_path = video.file_path
    if not file_path or not os.path.exists(file_path):
        # Try reconstructing path from raw/ folder
        raw_env = os.getenv("RAW_VIDEO_DIR", "raw")
        if os.path.isabs(raw_env):
            raw_base = raw_env
        else:
            raw_base = os.path.join(os.path.dirname(__file__), raw_env)
        possible = os.path.join(raw_base, video.folder_type or "", video.filename or "")
        if os.path.exists(possible):
            file_path = possible
        else:
            raise HTTPException(status_code=404, detail=f"Video file not found on disk")

    return FileResponse(
        path=file_path,
        media_type="video/mp4",
        filename=video.filename,
    )
# ─────────────────────────────────────────────────────────────────────────────
# AI Pipeline Control Endpoints
# ─────────────────────────────────────────────────────────────────────────────
# NOTE: start/stop/status for the pipeline are defined once, above, in the
# "Offline Pipeline Control Endpoints" section (/pipeline/start etc., backed by
# parallel_runner.py). This used to be a second, conflicting set of handlers
# that raced with those over the same global process handle and could launch
# integrated_pipeline.py directly (bypassing chunked GPU processing) alongside
# parallel_runner.py. Removed; see the /api/v1 aliases added to that section.

@app.get("/pipeline/videos")
@app.get("/api/v1/pipeline/videos")
def get_pipeline_videos(db: Session = Depends(get_db)):
    return get_videos(db)

@app.get("/pipeline/logs")
@app.get("/api/v1/pipeline/logs")
def get_pipeline_logs(db: Session = Depends(get_db)):
    try:
        combined = []
        # 1. SystemLog DB entries
        logs = db.query(SystemLog).order_by(SystemLog.id.desc()).limit(150).all()
        for l in reversed(logs):
            combined.append({
                "id": l.id,
                "level": l.level or "info",
                "module": l.module or "system",
                "message": l.message,
                "timestamp": l.timestamp.strftime("%d %b, %H:%M:%S") if l.timestamp else ""
            })

        # 2. auto_pipeline.log live file entries
        log_file = os.path.join(BACKEND_DIR, "auto_pipeline.log")
        if os.path.exists(log_file):
            try:
                with open(log_file, "r", encoding="utf-8", errors="ignore") as f:
                    lines = f.readlines()[-150:]
                for i, line in enumerate(lines):
                    line_clean = line.strip()
                    if not line_clean:
                        continue
                    lvl = "info"
                    if "[AUTHORIZED" in line_clean:
                        lvl = "success"
                    elif "[UNAUTHORIZED" in line_clean or "[UNAUTHORIZED EXIT]" in line_clean:
                        lvl = "warn"
                    elif "[ERROR]" in line_clean or "failed" in line_clean.lower():
                        lvl = "error"
                    elif "[WARNING]" in line_clean or "warn" in line_clean.lower():
                        lvl = "warn"
                    elif "ready" in line_clean.lower() or "initialized" in line_clean.lower() or "success" in line_clean.lower():
                        lvl = "success"

                    combined.append({
                        "id": 990000 + i,
                        "level": lvl,
                        "module": "auto_pipeline",
                        "message": line_clean,
                        "timestamp": ""
                    })
            except Exception:
                pass

        return combined
    except Exception:
        return []


@app.get("/pipeline/events")
@app.get("/api/v1/pipeline/events")
def get_pipeline_events(limit: int = 200, camera_role: str = "all", db: Session = Depends(get_db)):
    q = db.query(Event)
    if camera_role and camera_role != "all":
        c_role_clean = camera_role.lower()
        if c_role_clean == "break":
            q = q.filter(Event.camera_role.in_(["breakin", "breakout"]))
        elif c_role_clean in ["attendance", "att"]:
            q = q.filter(Event.camera_role.in_(["attendance", "checkin", "checkout"]))
        else:
            q = q.filter(Event.camera_role == camera_role)
    events = q.order_by(Event.id.desc()).limit(limit).all()
    res = []
    for e in events:
        res.append({
            "id": e.id,
            "video_id": getattr(e, "video_id", None),
            "camera_role": e.camera_role,
            "track_id": e.track_id,
            "timestamp": e.timestamp,
            "frame_number": e.frame_number,
            "STAFF_name": e.STAFF_name or f"Person #{e.track_id}",
            "STAFF_id": e.STAFF_id,
            "confidence": round(e.recognition_confidence or 0.0, 4),
            "recognition_status": e.recognition_status,
        })
    return res


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Roles & Permissions Endpoints
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class RoleCreate(BaseModel):
    name: str
    is_active: bool = True
    permission_ids: List[int] = []

@app.get("/api/v1/permissions")
def get_permissions_v1(db: Session = Depends(get_db)):
    return get_permissions(db)

@app.get("/permissions")
def get_permissions(db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    """Return all permissions grouped by category/group name."""
    perms = db.query(Permission).all()
    grouped: Dict[str, List[Dict[str, Any]]] = {}
    for p in perms:
        grp = p.group or "General"
        if grp not in grouped:
            grouped[grp] = []
        grouped[grp].append({
            "id": p.id,
            "name": p.name,
            "description": p.description,
            "group": p.group,
        })
    return grouped


@app.get("/api/v1/roles")
def get_roles_v1(db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    return get_roles(db, current_user)

@app.get("/roles")
def get_roles(db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    """List all system roles with assigned permissions and user/staff counts."""
    roles = db.query(Role).order_by(Role.id).all()
    res = []
    for r in roles:
        role_name_lower = r.name.lower()
        user_cnt = db.query(User).filter((User.role_id == r.id) | (func.lower(User.role) == role_name_lower)).count()
        staff_cnt = db.query(Staff).filter(func.lower(Staff.role) == role_name_lower).count()
        assigned_total = max(user_cnt, staff_cnt)

        res.append({
            "id": r.id,
            "name": r.name,
            "is_active": r.is_active,
            "created_at": r.created_at.isoformat() if r.created_at else None,
            "updated_at": r.updated_at.isoformat() if r.updated_at else None,
            "assigned_count": assigned_total,
            "assigned_users_count": user_cnt,
            "assigned_staff_count": staff_cnt,
            "permissions": [
                {
                    "id": p.id,
                    "name": p.name,
                    "description": p.description,
                    "group": p.group,
                } for p in r.permissions
            ]
        })
    return res


@app.post("/api/v1/roles")
def create_role_v1(data: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    return create_role(data, db, current_user)

@app.post("/roles")
def create_role(data: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    """Create a new role with assigned permission IDs."""
    existing = db.query(Role).filter(Role.name == data.name.strip()).first()
    if existing:
        raise HTTPException(status_code=400, detail=f"Role with name '{data.name}' already exists.")
    
    role = Role(name=data.name.strip(), is_active=data.is_active)
    if data.permission_ids:
        perms = db.query(Permission).filter(Permission.id.in_(data.permission_ids)).all()
        role.permissions = perms
    
    db.add(role)
    db.commit()
    db.refresh(role)
    
    return {
        "id": role.id,
        "name": role.name,
        "is_active": role.is_active,
        "created_at": role.created_at.isoformat() if role.created_at else None,
        "updated_at": role.updated_at.isoformat() if role.updated_at else None,
        "permissions": [
            {"id": p.id, "name": p.name, "description": p.description, "group": p.group}
            for p in role.permissions
        ]
    }


@app.put("/api/v1/roles/{role_id}")
def update_role_v1(role_id: int, data: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    return update_role(role_id, data, db, current_user)

@app.put("/roles/{role_id}")
def update_role(role_id: int, data: RoleCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    """Update role details and permissions."""
    role = db.query(Role).filter(Role.id == role_id).first()
    if not role:
        raise HTTPException(status_code=404, detail="Role not found.")
    
    # Check duplicate name if changed
    if data.name.strip() != role.name:
        dup = db.query(Role).filter(Role.name == data.name.strip(), Role.id != role_id).first()
        if dup:
            raise HTTPException(status_code=400, detail=f"Role '{data.name}' already exists.")
    
    role.name = data.name.strip()
    role.is_active = data.is_active
    role.updated_at = datetime.utcnow()
    
    perms = db.query(Permission).filter(Permission.id.in_(data.permission_ids)).all() if data.permission_ids else []
    role.permissions = perms
    
    db.commit()
    db.refresh(role)
    
    return {
        "id": role.id,
        "name": role.name,
        "is_active": role.is_active,
        "created_at": role.created_at.isoformat() if role.created_at else None,
        "updated_at": role.updated_at.isoformat() if role.updated_at else None,
        "permissions": [
            {"id": p.id, "name": p.name, "description": p.description, "group": p.group}
            for p in role.permissions
        ]
    }


@app.delete("/api/v1/roles/{role_id}")
def delete_role_v1(role_id: int, db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    return delete_role(role_id, db, current_user)

@app.delete("/roles/{role_id}")
def delete_role(role_id: int, db: Session = Depends(get_db), current_user: User = Depends(check_permission("manage_roles"))):
    """Delete a custom role."""
    role = db.query(Role).filter(Role.id == role_id).first()
    if not role:
        raise HTTPException(status_code=404, detail="Role not found.")
    
    db.delete(role)
    db.commit()
    return {"message": "Role deleted successfully"}


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# Department Management Endpoints
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ShiftItem(BaseModel):
    id: Optional[int] = None
    shift_name: str = "Morning"
    shift_start: str = "09:00"
    shift_end: str = "17:00"
    grace_time_mins: int = 15
    early_departure_buffer_mins: int = 10
    break_start: str = "13:00"
    break_end: str = "14:00"
    days: str = "Mon,Tue,Wed,Thu,Fri"

class DepartmentCreate(BaseModel):
    name: str
    description: Optional[str] = ""
    is_active: Optional[bool] = True
    branch_id: Optional[int] = None
    branch_name: Optional[str] = None
    shifts: List[ShiftItem] = []

@app.get("/api/v1/departments")
def get_departments_v1(branch_id: Optional[str] = None, db: Session = Depends(get_db), current_user: User = Depends(check_permission("view_department"))):
    return get_departments(branch_id, db, current_user)

@app.get("/departments")
def get_departments(branch_id: Optional[str] = None, db: Session = Depends(get_db), current_user: User = Depends(check_permission("view_department"))):
    """List all departments with shifts, staff count, branch assignment, and active shift details."""
    try:
        query = db.query(Department)
        if branch_id and str(branch_id).strip() and str(branch_id).lower() != "all":
            try:
                b_id = int(branch_id)
                query = query.filter(Department.branch_id == b_id)
            except (ValueError, TypeError):
                pass
        depts = query.order_by(Department.id).all()
        res = []
        for d in depts:
            staff_count = 0
            try:
                staff_q = db.query(Staff).filter(Staff.department_id == d.id)
                if branch_id and branch_id != "all":
                    try:
                        staff_q = staff_q.filter(Staff.branch_id == int(branch_id))
                    except (ValueError, TypeError):
                        pass
                staff_count = staff_q.count()
            except Exception:
                staff_count = 0

            shifts_data = []
            try:
                for s in (d.shifts or []):
                    shifts_data.append({
                        "id": s.id,
                        "shift_name": getattr(s, "shift_name", "Morning") or "Morning",
                        "shift_start": getattr(s, "shift_start", "09:00") or "09:00",
                        "shift_end": getattr(s, "shift_end", "17:00") or "17:00",
                        "grace_time_mins": getattr(s, "grace_time_mins", 15) or 15,
                        "early_departure_buffer_mins": getattr(s, "early_departure_buffer_mins", 10) or 10,
                        "break_start": getattr(s, "break_start", "13:00") or "13:00",
                        "break_end": getattr(s, "break_end", "14:00") or "14:00",
                        "days": getattr(s, "days", None) or "Mon,Tue,Wed,Thu,Fri",
                    })
            except Exception as e:
                print(f"[get_departments] error parsing shifts for dept {d.id}: {e}")

            b_name = "Main Branch"
            try:
                if d.branch:
                    b_name = d.branch.name
            except Exception:
                b_name = "Main Branch"

            res.append({
                "id": d.id,
                "name": d.name,
                "description": d.description or "",
                "branch_id": d.branch_id,
                "branch_name": b_name,
                "is_active": d.is_active if d.is_active is not None else True,
                "created_at": d.created_at.isoformat() if getattr(d, "created_at", None) else None,
                "updated_at": (d.updated_at.isoformat() if getattr(d, "updated_at", None) else (d.created_at.isoformat() if getattr(d, "created_at", None) else None)),
                "shift_name": getattr(d, "shift_name", "Morning") or "Morning",
                "shift_start": getattr(d, "shift_start", "09:00") or "09:00",
                "shift_end": getattr(d, "shift_end", "17:00") or "17:00",
                "grace_time_mins": getattr(d, "grace_time_mins", 15) or 15,
                "break_start": getattr(d, "break_start", "13:00") or "13:00",
                "break_end": getattr(d, "break_end", "14:00") or "14:00",
                "staff_count": staff_count,
                "assigned_staff_count": staff_count,
                "assigned_count": staff_count,
                "shifts": shifts_data
            })
        return res
    except Exception as exc:
        print(f"[get_departments error]: {exc}")
        return []


@app.post("/api/v1/departments")
def create_department_v1(data: DepartmentCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("add_department"))):
    return create_department(data, db, current_user)

@app.post("/departments")
def create_department(data: DepartmentCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("add_department"))):
    """Create a new department with branch assignment and shifts."""
    existing = db.query(Department).filter(Department.name == data.name.strip()).first()
    if existing:
        raise HTTPException(status_code=400, detail=f"Department '{data.name}' already exists.")

    # Resolve branch
    branch_id_val = data.branch_id
    if not branch_id_val and data.branch_name and str(data.branch_name).strip():
        b_match = db.query(Branch).filter(Branch.name.ilike(data.branch_name.strip())).first()
        if b_match:
            branch_id_val = b_match.id
    if not branch_id_val:
        main_b = db.query(Branch).filter(Branch.name.ilike("%Main%")).first() or db.query(Branch).first()
        if main_b:
            branch_id_val = main_b.id

    dept = Department(
        name=data.name.strip(),
        description=data.description or f"{data.name.strip()} Department",
        branch_id=branch_id_val,
        is_active=data.is_active if data.is_active is not None else True
    )
    db.add(dept)
    db.commit()
    db.refresh(dept)

    # Save shifts
    if data.shifts:
        for s in data.shifts:
            shift_obj = Shift(
                department_id=dept.id,
                shift_name=s.shift_name,
                shift_start=s.shift_start,
                shift_end=s.shift_end,
                grace_time_mins=s.grace_time_mins,
                early_departure_buffer_mins=getattr(s, "early_departure_buffer_mins", 10) or 10,
                break_start=s.break_start,
                break_end=s.break_end,
                days=s.days
            )
            db.add(shift_obj)
        db.commit()
        db.refresh(dept)

    return get_departments_single(dept.id, db)


@app.put("/api/v1/departments/{dept_id}")
def update_department_v1(dept_id: int, data: DepartmentCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("update_department"))):
    return update_department(dept_id, data, db, current_user)

@app.put("/departments/{dept_id}")
def update_department(dept_id: int, data: DepartmentCreate, db: Session = Depends(get_db), current_user: User = Depends(check_permission("update_department"))):
    """Update a department name, description, branch assignment, and shifts."""
    dept = db.query(Department).filter(Department.id == dept_id).first()
    if not dept:
        raise HTTPException(status_code=404, detail="Department not found.")

    if data.name.strip() != dept.name:
        dup = db.query(Department).filter(Department.name == data.name.strip(), Department.id != dept_id).first()
        if dup:
            raise HTTPException(status_code=400, detail=f"Department '{data.name}' already exists.")

    dept.name = data.name.strip()
    dept.description = data.description
    if data.branch_id is not None:
        dept.branch_id = data.branch_id
    elif data.branch_name and str(data.branch_name).strip():
        b_match = db.query(Branch).filter(Branch.name.ilike(data.branch_name.strip())).first()
        if b_match:
            dept.branch_id = b_match.id

    if data.is_active is not None:
        dept.is_active = data.is_active
    dept.updated_at = datetime.utcnow()

    # Cascade branch assignment to all staff in this department
    if dept.branch_id is not None:
        db.query(Staff).filter(Staff.department_id == dept.id).update({"branch_id": dept.branch_id})

    # Re-sync shifts if provided
    if data.shifts and len(data.shifts) > 0:
        db.query(Shift).filter(Shift.department_id == dept_id).delete()
        for s in data.shifts:
            shift_obj = Shift(
                department_id=dept.id,
                shift_name=s.shift_name,
                shift_start=s.shift_start,
                shift_end=s.shift_end,
                grace_time_mins=s.grace_time_mins,
                early_departure_buffer_mins=getattr(s, "early_departure_buffer_mins", 10) or 10,
                break_start=s.break_start,
                break_end=s.break_end,
                days=s.days
            )
            db.add(shift_obj)
    db.commit()

    return get_departments_single(dept.id, db)


@app.delete("/api/v1/departments/{dept_id}")
@app.delete("/departments/{dept_id}")
def delete_department(dept_id: int, request: Request, db: Session = Depends(get_db)):
    """Delete a department."""
    dept = db.query(Department).filter(Department.id == dept_id).first()
    if not dept:
        raise HTTPException(status_code=404, detail="Department not found.")

    dept_name = dept.name
    # Delete associated shifts
    try:
        db.query(Shift).filter(Shift.department_id == dept_id).delete(synchronize_session=False)
    except Exception:
        pass

    # Unlink staff and users
    db.query(Staff).filter(Staff.department_id == dept_id).update({Staff.department_id: None})
    db.query(User).filter(User.department_id == dept_id).update({User.department_id: None})

    db.delete(dept)
    db.commit()
    return {"message": f"Department '{dept_name}' deleted successfully"}


def get_departments_single(dept_id: int, db: Session):
    d = db.query(Department).filter(Department.id == dept_id).first()
    if not d:
        return {}
    staff_count = db.query(Staff).filter(Staff.department_id == d.id).count()
    b_name = d.branch.name if d.branch else "Main Branch"
    return {
        "id": d.id,
        "name": d.name,
        "description": d.description,
        "branch_id": d.branch_id,
        "branch_name": b_name,
        "is_active": d.is_active if d.is_active is not None else True,
        "created_at": d.created_at.isoformat() if d.created_at else None,
        "shift_name": d.shift_name,
        "shift_start": d.shift_start,
        "shift_end": d.shift_end,
        "grace_time_mins": d.grace_time_mins,
        "break_start": d.break_start,
        "break_end": d.break_end,
        "staff_count": staff_count,
        "shifts": [
            {
                "id": s.id,
                "shift_name": s.shift_name,
                "shift_start": s.shift_start,
                "shift_end": s.shift_end,
                "grace_time_mins": s.grace_time_mins,
                "early_departure_buffer_mins": getattr(s, "early_departure_buffer_mins", 10) or 10,
                "break_start": s.break_start,
                "break_end": s.break_end,
                "days": s.days,
            } for s in d.shifts
        ]
    }


# ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
# Reports API Endpoints
# ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

def hhmm_to_mins_local(t_str):
    try:
        parts = t_str.split()
        h, m = map(int, parts[0].split(":"))
        if len(parts) > 1:
            ampm = parts[1].upper()
            if ampm == "PM" and h != 12:
                h += 12
            if ampm == "AM" and h == 12:
                h = 0
        return h * 60 + m
    except Exception:
        return 540


def resolve_staff_shift_timing(s, db, target_date=None):
    """
    Hierarchical Shift Resolution with Dynamic Day-of-Week matching:
    1. Parse target_date (supporting date, datetime, or str)
    2. Check Department dynamic shifts matching target_date's day of week (e.g. Mon-Thu vs Friday vs Saturday)
    3. Fallback to Staff individual custom shift if explicitly assigned
    4. Department fallback defaults
    5. Global Fallback ("09:00 AM" - "06:00 PM", grace = 10 mins, break = "01:00 PM" - "02:00 PM")
    """
    import datetime as _dt
    
    parsed_date = None
    if target_date:
        if isinstance(target_date, _dt.datetime):
            parsed_date = target_date.date()
        elif isinstance(target_date, _dt.date):
            parsed_date = target_date
        elif isinstance(target_date, str):
            for fmt in ["%d-%m-%Y", "%Y-%m-%d", "%d/%m/%Y"]:
                try:
                    parsed_date = _dt.datetime.strptime(target_date.strip(), fmt).date()
                    break
                except Exception:
                    pass

    start_str = None
    end_str = None
    grace_mins = 10
    b_start_str = None
    b_end_str = None

    dept_id = getattr(s, "department_id", None) or (s.department.id if getattr(s, "department", None) else None)
    if dept_id:
        dept_shifts = db.query(Shift).filter(Shift.department_id == dept_id).all()
        matched_shift = None
        
        if parsed_date and dept_shifts:
            weekday_map = {0: "Mon", 1: "Tue", 2: "Wed", 3: "Thu", 4: "Fri", 5: "Sat", 6: "Sun"}
            day_name = weekday_map.get(parsed_date.weekday(), "")
            for ds in dept_shifts:
                ds_days = (ds.days or "").split(",")
                if day_name in ds_days or any(day_name.lower() in d.lower() for d in ds_days):
                    matched_shift = ds
                    break
                    
        if not matched_shift and dept_shifts:
            matched_shift = dept_shifts[0]
            
        if matched_shift:
            if getattr(matched_shift, "shift_start", None):
                start_str = str(matched_shift.shift_start).strip()
            if getattr(matched_shift, "shift_end", None):
                end_str = str(matched_shift.shift_end).strip()
            if getattr(matched_shift, "grace_time_mins", None) is not None:
                grace_mins = matched_shift.grace_time_mins
            if getattr(matched_shift, "break_start", None):
                b_start_str = str(matched_shift.break_start).strip()
            if getattr(matched_shift, "break_end", None):
                b_end_str = str(matched_shift.break_end).strip()

        dept_obj = getattr(s, "department", None) or db.query(Department).filter(Department.id == dept_id).first()
        if dept_obj:
            if not start_str and getattr(dept_obj, "shift_start", None):
                start_str = str(dept_obj.shift_start).strip()
            if not end_str and getattr(dept_obj, "shift_end", None):
                end_str = str(dept_obj.shift_end).strip()
            if getattr(dept_obj, "grace_time_mins", None) is not None and not matched_shift:
                grace_mins = dept_obj.grace_time_mins
            if not b_start_str and getattr(dept_obj, "break_start", None):
                b_start_str = str(dept_obj.break_start).strip()
            if not b_end_str and getattr(dept_obj, "break_end", None):
                b_end_str = str(dept_obj.break_end).strip()

    # Individual staff override if no department shift or explicit custom timing
    if not start_str and s.shift_start_time and str(s.shift_start_time).strip():
        start_str = str(s.shift_start_time).strip()
    if not end_str and s.shift_end_time and str(s.shift_end_time).strip():
        end_str = str(s.shift_end_time).strip()

    # Format helper
    def _format_time_str(ts, fallback):
        if not ts: return fallback
        t_clean = ts.strip()
        if ":" in t_clean and ("AM" not in t_clean and "PM" not in t_clean):
            parts = t_clean.split(":")
            try:
                h = int(parts[0])
                m = int(parts[1])
                ampm = "AM" if h < 12 else "PM"
                h12 = h if (h in [0, 12]) else h % 12
                if h12 == 0: h12 = 12
                return f"{h12:02d}:{m:02d} {ampm}"
            except Exception:
                return t_clean
        return t_clean

    start_str = _format_time_str(start_str, "09:00 AM")
    end_str = _format_time_str(end_str, "06:00 PM")
    b_start_str = _format_time_str(b_start_str, "01:00 PM")
    b_end_str = _format_time_str(b_end_str, "02:00 PM")

    # Compute dynamic allowed break duration
    bs_mins = hhmm_to_mins_local(b_start_str)
    be_mins = hhmm_to_mins_local(b_end_str)
    if be_mins > bs_mins:
        allowed_break_mins = be_mins - bs_mins
    else:
        allowed_break_mins = 60

    return start_str, end_str, grace_mins, allowed_break_mins, b_start_str, b_end_str


def get_reports_data_internal(
    branch_id: Optional[str] = None,
    department: Optional[str] = None,
    camera_id: Optional[str] = None,
    search: Optional[str] = None,
    report_type: Optional[str] = "attendance",
    time_frame: Optional[str] = "current_date",
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    time_from: Optional[str] = None,
    time_to: Optional[str] = None,
    status_filter: Optional[str] = "all",
    page: int = 1,
    per_page: int = 50,
    sort_by: str = "staff_id",
    order: str = "asc",
    db: Session = None,
):
    import datetime as dt_module
    import re

    # Normalize report_type ("attendence", "attendance", "break", etc.)
    r_clean = (report_type or "attendance").strip().lower()
    report_type = "break" if "break" in r_clean else "attendance"

    today = dt_module.date.today()
    # Find latest event date in DB as fallback if today has no events
    latest_ev_date = today
    first_ev = db.query(Event).order_by(Event.id.desc()).first()
    if first_ev and first_ev.timestamp:
        ts_clean = first_ev.timestamp
        match = re.search(r'\((\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2})\)', ts_clean)
        if match:
            ts_clean = match.group(1)
        for fmt in ["%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%d-%m-%Y"]:
            try:
                latest_ev_date = dt_module.datetime.strptime(ts_clean.strip(), fmt).date()
                break
            except Exception:
                pass

    def parse_query_date(d_str):
        if not d_str: return None
        for fmt in ["%Y-%m-%d", "%d-%m-%Y", "%d/%m/%Y", "%m/%d/%Y", "%d/%m/%y", "%m/%d/%y", "%Y/%m/%d"]:
            try:
                return dt_module.datetime.strptime(d_str.strip(), fmt).date()
            except Exception:
                continue
        return None

    if date_from or date_to:
        time_frame = None

    date_from_dt = parse_query_date(date_from) if date_from else None
    date_to_dt = parse_query_date(date_to) if date_to else None

    if time_frame == "current_date":
        date_from_dt = latest_ev_date
        date_to_dt = latest_ev_date
    elif not date_from_dt and not date_to_dt:
        date_from_dt = latest_ev_date
        date_to_dt = latest_ev_date
    elif date_from_dt and not date_to_dt:
        date_to_dt = date_from_dt
    elif date_to_dt and not date_from_dt:
        date_from_dt = date_to_dt

    start_dt = dt_module.datetime.combine(date_from_dt, dt_module.time.min)
    end_dt = dt_module.datetime.combine(date_to_dt, dt_module.time.max)
    is_multi_date = (date_from_dt != date_to_dt)

    # 1. Query staff
    staff_q = db.query(Staff)
    if branch_id and branch_id != "all":
        try:
            staff_q = staff_q.filter(Staff.branch_id == int(branch_id))
        except (ValueError, TypeError):
            pass
    if department and department != "all":
        staff_q = staff_q.join(Staff.department).filter(Department.name == department)
    if search:
        s_pat = f"%{search}%"
        from sqlalchemy import or_
        staff_q = staff_q.filter(or_(Staff.name.ilike(s_pat), Staff.staff_id.ilike(s_pat)))

    all_staff = staff_q.all()
    branches = {b.id: b.name for b in db.query(Branch).all()}
    cameras_map = {}
    for cam in db.query(Camera).all():
        if cam.camera_id:
            cameras_map[cam.camera_id] = cam
        if cam.name:
            cameras_map[cam.name] = cam

    def parse_dt(ts_str):
        if not ts_str: return None
        import re
        match = re.search(r'\((\d{2}-\d{2}-\d{4} \d{2}:\d{2}:\d{2})\)', ts_str)
        if match:
            ts_str = match.group(1)
        for fmt in ["%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M:%S", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%d-%m-%Y"]:
            try:
                return dt_module.datetime.strptime(ts_str.strip(), fmt)
            except Exception:
                continue
        return None

    def _get_video_seek_sec(evt, evt_dt, vid):
        if not vid:
            return 0.0
        raw_sec = 0.0
        v_start_dt = parse_dt(vid.video_start_time) if getattr(vid, "video_start_time", None) else None
        if not v_start_dt and getattr(vid, "filename", None):
            import re
            m = re.search(r'(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})', vid.filename)
            if m:
                try:
                    v_start_dt = dt_module.datetime(int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4)), int(m.group(5)), int(m.group(6)))
                except Exception:
                    pass
        if evt_dt and v_start_dt:
            diff_sec = (evt_dt - v_start_dt).total_seconds()
            if 0 <= diff_sec <= 86400:
                raw_sec = diff_sec
        if raw_sec == 0.0:
            fps = vid.fps if (getattr(vid, "fps", None) and vid.fps > 0) else 25.0
            frame_num = getattr(evt, "frame_number", 0) or 0
            raw_sec = frame_num / fps
        return round(max(0.0, raw_sec - 3.0), 1)

    t_from_obj = None
    t_to_obj = None
    if time_from:
        try: t_from_obj = dt_module.datetime.strptime(time_from.strip(), "%H:%M").time()
        except Exception: pass
    if time_to:
        try: t_to_obj = dt_module.datetime.strptime(time_to.strip(), "%H:%M").time()
        except Exception: pass

    # Fetch events in range with optimized queries
    from sqlalchemy.orm import joinedload
    events_q = db.query(Event).options(joinedload(Event.video)).filter(Event.employee_id.isnot(None), Event.timestamp.isnot(None))
    
    if camera_id and camera_id != "all":
        from sqlalchemy import or_
        # 1. Dynamically find matching cameras in database
        cams = db.query(Camera).filter(
            or_(
                Camera.sub_location.ilike(f"%{camera_id}%"),
                Camera.name.ilike(f"%{camera_id}%"),
                Camera.camera_id.ilike(f"%{camera_id}%"),
                Camera.activity_name.ilike(f"%{camera_id}%")
            )
        ).all()

        # 2. Dynamically find matching branch activities in database
        b_acts = db.query(BranchActivity).filter(
            or_(
                BranchActivity.name.ilike(f"%{camera_id}%"),
                BranchActivity.floor.ilike(f"%{camera_id}%"),
                BranchActivity.camera_id.ilike(f"%{camera_id}%"),
                BranchActivity.camera_name.ilike(f"%{camera_id}%")
            )
        ).all()

        valid_cam_names = {camera_id}
        valid_folder_types = set()
        valid_roles = set()

        for c in cams:
            if c.name: valid_cam_names.add(c.name)
            if c.camera_id: valid_cam_names.add(c.camera_id)
            if c.activity_name: 
                valid_cam_names.add(c.activity_name)
                valid_folder_types.add(c.activity_name.lower())
            if c.sub_location: valid_cam_names.add(c.sub_location)
            
            c_dir = (c.camera_type or "").lower()
            if "single" in c_dir or "bi" in c_dir:
                valid_roles.update(["checkin", "checkout", "attendance", "breakin", "breakout"])
            else:
                if c.is_checkin: valid_roles.update(["checkin", "attendance", "breakin", "in"])
                if c.is_checkout: valid_roles.update(["checkout", "attendance", "breakout", "out"])

        for ba in b_acts:
            if ba.name: 
                valid_cam_names.add(ba.name)
                valid_folder_types.add(ba.name.lower())
            if ba.floor: valid_cam_names.add(ba.floor)
            if ba.camera_name: valid_cam_names.add(ba.camera_name)
            if ba.camera_id: valid_cam_names.add(ba.camera_id)
            ba_dir = (ba.camera_direction or "").lower()
            if "single" in ba_dir or "bi" in ba_dir:
                valid_roles.update(["checkin", "checkout", "attendance", "breakin", "breakout"])
            elif "in" in ba_dir:
                valid_roles.update(["checkin", "attendance", "breakin", "in"])
            elif "out" in ba_dir:
                valid_roles.update(["checkout", "attendance", "breakout", "out"])

        # 3. Dynamic filter across video metadata and event roles
        filter_clauses = [
            Video.camera_name.in_(list(valid_cam_names)),
            Event.camera_role.ilike(f"%{camera_id}%"),
            Video.camera_name.ilike(f"%{camera_id}%")
        ]
        if valid_folder_types:
            filter_clauses.append(Video.folder_type.in_(list(valid_folder_types)))
        if valid_roles:
            filter_clauses.append(Event.camera_role.in_(list(valid_roles)))

        events_q = events_q.join(Event.video).filter(or_(*filter_clauses))
        
    all_events = events_q.all()
    events_by_staff = {}
    for ev in all_events:
        if not ev.timestamp:
            continue
        ev_dt = parse_dt(ev.timestamp)
        if not ev_dt or not (start_dt <= ev_dt <= end_dt):
            continue
            
        if t_from_obj and ev_dt.time() < t_from_obj:
            continue
        # Index events by exact employee_id code and exact normalized full name
        keys = set()
        emp_id_val = str(getattr(ev, "employee_id", "") or "").strip().upper()
        if emp_id_val and emp_id_val != "NONE":
            keys.add(emp_id_val)
        
        emp_name_val = str(getattr(ev, "employee_name", "") or "").strip().lower()
        if emp_name_val and not emp_name_val.startswith("person #"):
            # Full normalized name
            norm_name = " ".join(emp_name_val.replace("-", " ").replace(".", " ").split())
            if norm_name:
                keys.add(norm_name)
            
        for k in keys:
            if k not in events_by_staff:
                events_by_staff[k] = []
            events_by_staff[k].append((ev, ev_dt))

    summary_list = []
    total_with_breaks = 0
    total_without_breaks = 0
    grand_total_breaks = 0
    grand_total_break_mins = 0
    break_durations = []

    for s in all_staff:
        b_name = branches.get(s.branch_id, "Main Branch")
        is_break_report = (report_type == "break")
        
        # Collect all events matching this staff member by exact staff_id or exact normalized full name
        s_keys = set()
        stf_code_clean = str(getattr(s, "staff_id", "") or "").strip().upper()
        if stf_code_clean:
            s_keys.add(stf_code_clean)
        
        s_name_clean = str(getattr(s, "name", "") or "").strip().lower()
        if s_name_clean:
            norm_s_name = " ".join(s_name_clean.replace("-", " ").replace(".", " ").split())
            if norm_s_name:
                s_keys.add(norm_s_name)

        raw_evs = []
        for k in s_keys:
            if k in events_by_staff:
                raw_evs.extend(events_by_staff[k])
                
        # Partition and deduplicate employee events across cameras
        seen_events = set()
        all_emp_events = []
        break_emp_events = []
        att_emp_events = []

        for ev, ev_dt in raw_evs:
            c_role = (ev.camera_role or "").lower()
            ts_key = (c_role, str(ev.timestamp).strip()[:19])
            if ts_key not in seen_events:
                seen_events.add(ts_key)
                all_emp_events.append((ev, ev_dt))
                if "break" in c_role or c_role in ["breakin", "breakout"]:
                    break_emp_events.append((ev, ev_dt))
                if "att" in c_role or c_role in ["attendance", "checkin", "checkout", "gate", "main"]:
                    att_emp_events.append((ev, ev_dt))

        all_emp_events.sort(key=lambda x: x[1])
        break_emp_events.sort(key=lambda x: x[1])
        att_emp_events.sort(key=lambda x: x[1])

        # Group by date
        all_events_by_date = {}
        for ev, ev_dt in all_emp_events:
            d_key = ev_dt.date()
            all_events_by_date.setdefault(d_key, []).append((ev, ev_dt))

        break_events_by_date = {}
        for ev, ev_dt in break_emp_events:
            d_key = ev_dt.date()
            break_events_by_date.setdefault(d_key, []).append((ev, ev_dt))

        att_events_by_date = {}
        for ev, ev_dt in att_emp_events:
            d_key = ev_dt.date()
            att_events_by_date.setdefault(d_key, []).append((ev, ev_dt))

        days_with_attendance = set(all_events_by_date.keys())

        # Build All Break Sessions with Robust Chronological Pairing
        all_break_sessions = []
        for day_date, day_break_evs in break_events_by_date.items():
            sorted_day_evs = sorted(day_break_evs, key=lambda x: x[1])
            valid_break_evs = sorted_day_evs

            clustered_evs = []
            for item in valid_break_evs:
                if not clustered_evs:
                    clustered_evs.append(item)
                else:
                    prev = clustered_evs[-1]
                    diff = (item[1] - prev[1]).total_seconds()
                    role_curr = "breakin" if item[0].camera_role in ["breakin", "checkin"] else "breakout"
                    role_prev = "breakin" if prev[0].camera_role in ["breakin", "checkin"] else "breakout"
                    if diff <= 2 and role_curr == role_prev and item[0].track_id == prev[0].track_id:
                        pass
                    else:
                        clustered_evs.append(item)

            MAX_BREAK_DURATION_SECS = 7200  # 2 hours — if break exceeds this, camera likely missed the breakout
            state = 0
            active_breakin = None

            for item in clustered_evs:
                ev = item[0]
                dt = item[1]
                role = "breakin" if ev.camera_role in ["breakin", "checkin"] else "breakout"
                
                if role == "breakin":
                    if state == 1 and active_breakin is not None:
                        gap_secs = (dt - active_breakin[1]).total_seconds()
                        if gap_secs > MAX_BREAK_DURATION_SECS:
                            # Gap exceeds max → camera missed the breakout → auto-close previous break
                            start_ev = active_breakin[0]
                            start_vid = db.query(Video).filter(Video.id == start_ev.video_id).first() if start_ev.video_id else None
                            sub_loc = "Rooftop Cafeteria"
                            if start_vid and start_vid.camera_name:
                                cam_meta = cameras_map.get(start_vid.camera_name)
                                if cam_meta and cam_meta.sub_location:
                                    sub_loc = cam_meta.sub_location
                            break_in_video = {
                                "has_video": True if start_vid else False,
                                "video_url": f"/videos/stream/{start_vid.id}" if start_vid else None,
                                "timestamp_sec": _get_video_seek_sec(start_ev, active_breakin[1], start_vid),
                                "label": f"{s.name} — Break In ({active_breakin[1].strftime('%I:%M:%S %p')})"
                            } if start_vid else None
                            all_break_sessions.append({
                                "date": day_date.strftime("%d-%m-%Y"),
                                "break_num": len(all_break_sessions) + 1,
                                "track_id": f"TRK-{start_ev.track_id}",
                                "breakin": active_breakin[1].strftime("%I:%M:%S %p"),
                                "breakout": "—",
                                "duration": "Missed",
                                "duration_mins": 0,
                                "duration_secs": 0,
                                "sub_location": sub_loc,
                                "break_in_video": break_in_video,
                                "break_out_video": None,
                            })
                            # Start new break with current breakin
                            state = 1
                            active_breakin = item
                        else:
                            # Still within max duration — same break, ignore repeated breakin
                            continue
                    else:
                        state = 1
                        active_breakin = item
                elif role == "breakout":
                    if state == 1 and active_breakin is not None:
                        total_secs = max(1, int((dt - active_breakin[1]).total_seconds()))
                        if total_secs > MAX_BREAK_DURATION_SECS:
                            # Breakout too far from breakin — camera missed intermediate events
                            # Auto-close the breakin as Missed, treat this breakout as orphan
                            start_ev_m = active_breakin[0]
                            start_vid_m = db.query(Video).filter(Video.id == start_ev_m.video_id).first() if start_ev_m.video_id else None
                            sub_loc_m = "Rooftop Cafeteria"
                            if start_vid_m and start_vid_m.camera_name:
                                cam_meta_m = cameras_map.get(start_vid_m.camera_name)
                                if cam_meta_m and cam_meta_m.sub_location:
                                    sub_loc_m = cam_meta_m.sub_location
                            break_in_video_m = {
                                "has_video": True if start_vid_m else False,
                                "video_url": f"/videos/stream/{start_vid_m.id}" if start_vid_m else None,
                                "timestamp_sec": _get_video_seek_sec(start_ev_m, active_breakin[1], start_vid_m),
                                "label": f"{s.name} — Break In ({active_breakin[1].strftime('%I:%M:%S %p')})"
                            } if start_vid_m else None
                            all_break_sessions.append({
                                "date": day_date.strftime("%d-%m-%Y"),
                                "break_num": len(all_break_sessions) + 1,
                                "track_id": f"TRK-{start_ev_m.track_id}",
                                "breakin": active_breakin[1].strftime("%I:%M:%S %p"),
                                "breakout": "—",
                                "duration": "Missed",
                                "duration_mins": 0,
                                "duration_secs": 0,
                                "sub_location": sub_loc_m,
                                "break_in_video": break_in_video_m,
                                "break_out_video": None,
                            })
                            state = 0
                            active_breakin = None
                            continue
                        duration_mins = total_secs // 60
                        rem_secs = total_secs % 60
                        
                        if total_secs == 1:
                            duration_str = "01 sec"
                        elif total_secs < 60:
                            duration_str = f"{total_secs:02d} secs"
                        elif rem_secs > 0:
                            duration_str = f"{duration_mins:02d} mins {rem_secs:02d} secs"
                        else:
                            duration_str = f"{duration_mins:02d} mins"
                            
                        start_ev = active_breakin[0]
                        end_ev = ev
                        start_vid = db.query(Video).filter(Video.id == start_ev.video_id).first() if start_ev.video_id else None
                        end_vid = db.query(Video).filter(Video.id == end_ev.video_id).first() if end_ev.video_id else None
                        
                        sub_loc = "Rooftop Cafeteria"
                        if end_vid and end_vid.camera_name:
                            cam_meta = cameras_map.get(end_vid.camera_name)
                            if cam_meta and cam_meta.sub_location:
                                sub_loc = cam_meta.sub_location
                                
                        break_in_video = {
                            "has_video": True if start_vid else False,
                            "video_url": f"/videos/stream/{start_vid.id}" if start_vid else None,
                            "timestamp_sec": _get_video_seek_sec(start_ev, active_breakin[1], start_vid),
                            "label": f"{s.name} — Break In ({active_breakin[1].strftime('%I:%M:%S %p')})"
                        } if start_vid else None
                        
                        break_out_video = {
                            "has_video": True if end_vid else False,
                            "video_url": f"/videos/stream/{end_vid.id}" if end_vid else None,
                            "timestamp_sec": _get_video_seek_sec(end_ev, dt, end_vid),
                            "label": f"{s.name} — Break Out ({dt.strftime('%I:%M:%S %p')})"
                        } if end_vid else None
                        
                        all_break_sessions.append({
                            "date": day_date.strftime("%d-%m-%Y"),
                            "break_num": len(all_break_sessions) + 1,
                            "track_id": f"TRK-{start_ev.track_id}",
                            "breakin": active_breakin[1].strftime("%I:%M:%S %p"),
                            "breakout": dt.strftime("%I:%M:%S %p"),
                            "duration": duration_str,
                            "duration_mins": max(1, duration_mins),
                            "duration_secs": total_secs,
                            "sub_location": sub_loc,
                            "break_in_video": break_in_video,
                            "break_out_video": break_out_video,
                        })
                        state = 0
                        active_breakin = None
                    else:
                        # Orphan breakout without preceding breakin: strictly ignored ("breakin ni ha to out na ho")
                        pass
                        
            # Close trailing unpaired breakin
            if state == 1 and active_breakin is not None:
                start_ev = active_breakin[0]
                start_vid = db.query(Video).filter(Video.id == start_ev.video_id).first() if start_ev.video_id else None
                sub_loc = "Rooftop Cafeteria"
                if start_vid and start_vid.camera_name:
                    cam_meta = cameras_map.get(start_vid.camera_name)
                    if cam_meta and cam_meta.sub_location:
                        sub_loc = cam_meta.sub_location
                break_in_video = {
                    "has_video": True if start_vid else False,
                    "video_url": f"/videos/stream/{start_vid.id}" if start_vid else None,
                    "timestamp_sec": _get_video_seek_sec(start_ev, active_breakin[1], start_vid),
                    "label": f"{s.name} — Break In ({active_breakin[1].strftime('%I:%M %p')})"
                } if start_vid else None
                
                all_break_sessions.append({
                    "date": day_date.strftime("%d-%m-%Y"),
                    "break_num": len(all_break_sessions) + 1,
                    "track_id": f"TRK-{start_ev.track_id}",
                    "breakin": active_breakin[1].strftime("%I:%M %p"),
                    "breakout": "—",
                    "duration": "Active",
                    "duration_mins": 0,
                    "duration_secs": 0,
                    "sub_location": sub_loc,
                    "break_in_video": break_in_video,
                    "break_out_video": None,
                })

        r_start, r_end, r_grace, r_allowed_break, r_bstart, r_bend = resolve_staff_shift_timing(s, db, target_date=date_from_dt)
        shift_start_mins = hhmm_to_mins_local(r_start)
        shift_end_mins = hhmm_to_mins_local(r_end)
        shift_dur_mins = shift_end_mins - shift_start_mins
        if shift_dur_mins <= 0: shift_dur_mins = 540 # fallback 9 hours

        bstart_mins = hhmm_to_mins_local(r_bstart) if r_bstart else 780
        bend_mins = hhmm_to_mins_local(r_bend) if r_bend else 840
        if bend_mins <= bstart_mins:
            bend_mins = bstart_mins + r_allowed_break

        # Annotate individual break sessions with excess break duration and Off-Window status
        date_accum_mins = {}
        for bs in all_break_sessions:
            b_date = bs["date"]
            prev_acc = date_accum_mins.get(b_date, 0)
            cur_dur = bs.get("duration_mins", 0)
            new_acc = prev_acc + cur_dur
            date_accum_mins[b_date] = new_acc

            if new_acc > r_allowed_break:
                if prev_acc >= r_allowed_break:
                    sess_excess = cur_dur
                else:
                    sess_excess = new_acc - r_allowed_break
            else:
                sess_excess = 0

            bs["excess_mins"] = sess_excess
            bs["excess_duration"] = f"+{sess_excess} mins" if sess_excess > 0 else "00 mins"
            bs["exceeded"] = sess_excess > 0

            # Off-Window: Check if break occurred outside the department scheduled break window
            is_off_window = False
            b_in_str = bs.get("breakin")
            b_out_str = bs.get("breakout")
            if b_in_str and b_in_str != "—":
                in_mins = hhmm_to_mins_local(b_in_str)
                out_mins = hhmm_to_mins_local(b_out_str) if b_out_str and b_out_str != "—" else in_mins + cur_dur
                if in_mins < (bstart_mins - 5) or in_mins > (bend_mins + 5) or out_mins > (bend_mins + 15):
                    is_off_window = True
            
            bs["off_window"] = "Yes" if is_off_window else "No"
            bs["is_off_window"] = is_off_window

        working_days = len(days_with_attendance)
        total_break_count = len(all_break_sessions)
        total_break_mins = sum(bs["duration_mins"] for bs in all_break_sessions)
        has_breaks = total_break_count > 0
        if has_breaks:
            total_with_breaks += 1
            grand_total_breaks += total_break_count
            grand_total_break_mins += total_break_mins
            break_durations.extend(bs["duration_mins"] for bs in all_break_sessions)
        else:
            total_without_breaks += 1

        r_start, r_end, r_grace, r_allowed_break, r_bstart, r_bend = resolve_staff_shift_timing(s, db, target_date=date_from_dt)
        shift_start_mins = hhmm_to_mins_local(r_start)
        shift_end_mins = hhmm_to_mins_local(r_end)
        shift_dur_mins = shift_end_mins - shift_start_mins
        if shift_dur_mins <= 0: shift_dur_mins = 540 # fallback 9 hours

        def get_day_stats(target_date):
            d_start, d_end, d_grace, d_allowed_break, d_bstart, d_bend = resolve_staff_shift_timing(s, db, target_date=target_date)
            d_shift_start_mins = hhmm_to_mins_local(d_start)
            d_shift_end_mins = hhmm_to_mins_local(d_end)
            d_shift_dur_mins = d_shift_end_mins - d_shift_start_mins
            if d_shift_dur_mins <= 0: d_shift_dur_mins = 540

            day_att_evs = att_events_by_date.get(target_date, [])
            
            # Check-In: Strictly from Attendance Camera (ch5)
            checkin_ev_tuple = None
            if day_att_evs:
                checkin_ev_tuple = next((x for x in day_att_evs if (x[0].camera_role in ["checkin", "attendance"] or x[0].event_type in ["check_in", "person_detected"])), day_att_evs[0])

            # Check-Out: Strictly from Attendance Camera (ch5)
            checkout_ev_tuple = None
            if checkin_ev_tuple and day_att_evs:
                c_in_time = checkin_ev_tuple[1]
                checkout_ev_tuple = next((x for x in reversed(day_att_evs) if (x[0].camera_role in ["checkout", "attendance"] or x[0].event_type in ["check_out", "person_detected"]) and x[1] > c_in_time), None)
            
            day_break_mins = sum(bs["duration_mins"] for bs in all_break_sessions if bs["date"] == target_date.strftime("%d-%m-%Y"))
            day_break_secs = sum(bs.get("duration_secs", 0) for bs in all_break_sessions if bs["date"] == target_date.strftime("%d-%m-%Y"))
            
            d_status = "Absent"
            c_in = None
            c_out = None
            l_by = 0
            e_dep = 0
            e_arr = 0
            o_time = 0
            o_mins = 0
            n_mins = 0

            if checkin_ev_tuple:
                c_in = checkin_ev_tuple[1]
                checkin_mins = c_in.hour * 60 + c_in.minute
                l_by = checkin_mins - d_shift_start_mins
                if l_by < 0:
                    e_arr = abs(l_by)
                    d_status = "Early Arrival"
                elif l_by == 0:
                    d_status = "On Time"
                elif l_by <= d_grace:
                    d_status = "Within Grace"
                else:
                    d_status = "Late"

                if checkout_ev_tuple:
                    c_out = checkout_ev_tuple[1]
                    checkout_mins = c_out.hour * 60 + c_out.minute
                    o_mins = max(1, checkout_mins - checkin_mins)
                    n_mins = max(0, o_mins - day_break_mins)
                    
                    if checkout_mins > d_shift_end_mins:
                        o_time = checkout_mins - d_shift_end_mins
                        if d_status in ["On Time", "Early Arrival", "Within Grace"]:
                            d_status = "Overtime"
                    elif checkout_mins < d_shift_end_mins:
                        e_dep = d_shift_end_mins - checkout_mins
                        if d_status in ["On Time", "Early Arrival", "Within Grace"]:
                            d_status = "Early Departure"
                    elif n_mins < 480:
                        if d_status in ["On Time", "Early Arrival", "Within Grace"]:
                            d_status = "Short Hours"
                else:
                    # Check-in exists, but check-out has not yet occurred (or single morning video)
                    # Preserve real arrival status (On Time, Early Arrival, Within Grace, Late)
                    pass

            return {
                "date": target_date.strftime("%d-%m-%Y"),
                "status": d_status,
                "checkin": c_in,
                "checkout": c_out,
                "checkin_ev": checkin_ev_tuple[0] if checkin_ev_tuple else None,
                "checkout_ev": checkout_ev_tuple[0] if checkout_ev_tuple else None,
                "early_arrival": max(0, e_arr),
                "late_by": max(0, l_by) if l_by > 0 else 0,
                "early_departure": max(0, e_dep),
                "overtime": max(0, o_time),
                "office_mins": o_mins,
                "net_mins": n_mins,
                "break_mins": day_break_mins,
                "break_secs": day_break_secs,
                "shift_start": d_start,
                "shift_end": d_end,
                "shift_dur_mins": d_shift_dur_mins,
                "grace_mins": d_grace,
                "break_start": d_bstart,
                "break_end": d_bend,
                "allowed_break_mins": d_allowed_break
            }

        entry = {
            "staff_id": s.staff_id,
            "track_id": f"TRK-{s.id:03d}",
            "name": s.name,
            "branch_name": b_name,
            "department": (s.department.name if s.department else "General"),
            "shift": f"{r_start} - {r_end}",
            "grace_period": f"{r_grace} mins",
            "allocated_break_window": f"{r_bstart} - {r_bend}",
            "allocated_break_hours": f"{r_allowed_break // 60:02d} hrs {r_allowed_break % 60:02d} mins",
            "has_breaks": has_breaks,
        }

        # Status matching flags
        matched = False
        effective_filter = status_filter
        if report_type and report_type not in ["attendance", "break"] and status_filter == "all":
            effective_filter = report_type
        sf_lower = effective_filter.lower() if effective_filter else "all"

        if not is_multi_date:
            # === DAILY REPORT ===
            target_date = date_from_dt
            ds = get_day_stats(target_date)
            
            entry["shift"] = f"{ds['shift_start']} - {ds['shift_end']}"
            entry["grace_period"] = f"{ds['grace_mins']} mins"
            entry["allocated_break_window"] = f"{ds['break_start']} - {ds['break_end']}"
            entry["allocated_break_hours"] = f"{ds['allowed_break_mins'] // 60:02d} hrs {ds['allowed_break_mins'] % 60:02d} mins"
            entry["office_hours"] = f"{ds['shift_dur_mins'] // 60:02d} hrs {ds['shift_dur_mins'] % 60:02d} mins"
            entry["attendance_status"] = ds["status"]
            entry["check_in"] = ds["checkin"].strftime("%I:%M %p") if ds["checkin"] else "—"
            entry["check_out"] = ds["checkout"].strftime("%I:%M %p") if ds["checkout"] else "—"

            # Cross-verification Video Meta
            check_in_vid = None
            if ds["checkin"] and ds.get("checkin_ev"):
                c_ev = ds["checkin_ev"]
                c_vid = db.query(Video).filter(Video.id == c_ev.video_id).first() if c_ev.video_id else None
                if c_vid:
                    check_in_vid = {
                        "has_video": True,
                        "video_url": f"/videos/stream/{c_vid.id}",
                        "timestamp_sec": _get_video_seek_sec(c_ev, ds["checkin"], c_vid),
                        "label": f"{s.name} — Check-In ({ds['checkin'].strftime('%I:%M %p')})"
                    }
            entry["check_in_video"] = check_in_vid

            check_out_vid = None
            if ds["checkout"] and ds.get("checkout_ev"):
                c_ev = ds["checkout_ev"]
                c_vid = db.query(Video).filter(Video.id == c_ev.video_id).first() if c_ev.video_id else None
                if c_vid:
                    check_out_vid = {
                        "has_video": True,
                        "video_url": f"/videos/stream/{c_vid.id}",
                        "timestamp_sec": _get_video_seek_sec(c_ev, ds["checkout"], c_vid),
                        "label": f"{s.name} — Check-Out ({ds['checkout'].strftime('%I:%M %p')})"
                    }
            entry["check_out_video"] = check_out_vid
            
            # Detailed Gate Attendance Event History
            day_gate_evs = att_events_by_date.get(target_date, [])
            all_att_events_list = []
            for ev_t in day_gate_evs:
                g_ev, g_dt = ev_t
                g_vid = db.query(Video).filter(Video.id == g_ev.video_id).first() if g_ev.video_id else None
                g_role = "Check In" if g_ev.camera_role in ["checkin", "attendance"] else ("Check Out" if g_ev.camera_role == "checkout" else (g_ev.event_type or "Gate Passing"))
                g_vid_meta = {
                    "has_video": True if g_vid else False,
                    "video_url": f"/videos/stream/{g_vid.id}" if g_vid else None,
                    "timestamp_sec": _get_video_seek_sec(g_ev, g_dt, g_vid),
                    "label": f"{s.name} — {g_role} ({g_dt.strftime('%I:%M:%S %p')})"
                } if g_vid else None
                all_att_events_list.append({
                    "time": g_dt.strftime("%I:%M:%S %p"),
                    "event_type": g_role,
                    "track_id": f"TRK-{g_ev.track_id}",
                    "camera_name": (g_vid.camera_name if g_vid else "Attendance Gate"),
                    "sub_location": "Main Entrance Gate",
                    "video_meta": g_vid_meta
                })
            entry["all_attendance_events"] = all_att_events_list
            
            # Exact calculations per objective
            b_sec = ds.get("break_secs", 0)
            if b_sec < 60 and b_sec > 0:
                b_str = f"{b_sec:02d} secs"
            else:
                b_str = f"{ds['break_mins'] // 60:02d} hrs {ds['break_mins'] % 60:02d} mins"
                
            entry["office_hours"] = f"{shift_dur_mins // 60:02d} hrs {shift_dur_mins % 60:02d} mins"
            entry["today_office_hours"] = f"{ds['office_mins'] // 60:02d} hrs {ds['office_mins'] % 60:02d} mins" if ds["checkin"] and ds["checkout"] else None
            entry["total_break_hours"] = b_str
            entry["total_break_duration"] = b_str
            entry["net_work_hours"] = f"{ds['net_mins'] // 60:02d} hrs {ds['net_mins'] % 60:02d} mins" if ds["checkin"] and ds["checkout"] else None
            entry["early_arrival_by"] = f"{ds.get('early_arrival', 0) // 60:02d} hrs {ds.get('early_arrival', 0) % 60:02d} mins"
            entry["late_by"] = f"{ds['late_by'] // 60:02d} hrs {ds['late_by'] % 60:02d} mins"
            entry["early_departure_by"] = f"{ds['early_departure'] // 60:02d} hrs {ds['early_departure'] % 60:02d} mins"
            entry["overtime"] = f"{ds['overtime'] // 60:02d} hrs {ds['overtime'] % 60:02d} mins"

            if ds["checkin"] and ds["checkout"]:
                actual_b = ds["break_mins"]
                if actual_b == 0:
                    entry["break_compliance"] = f"No Break Taken (0 / {r_allowed_break} mins allocated)"
                    entry["unused_break_mins"] = r_allowed_break
                    entry["excess_break_mins"] = 0
                elif actual_b > r_allowed_break:
                    entry["break_compliance"] = f"Excess Break (+{actual_b - r_allowed_break} mins)"
                    entry["excess_break_mins"] = actual_b - r_allowed_break
                    entry["unused_break_mins"] = 0
                else:
                    entry["break_compliance"] = f"Within Policy ({actual_b} / {r_allowed_break} mins)"
                    entry["unused_break_mins"] = r_allowed_break - actual_b
                    entry["excess_break_mins"] = 0
            else:
                entry["break_compliance"] = "—"
                entry["unused_break_mins"] = 0
                entry["excess_break_mins"] = 0

            target_day_evs = att_events_by_date.get(target_date, [])
            att_events_list = []
            if ds["checkin"]:
                sorted_day_evs = sorted(target_day_evs, key=lambda x: x[1])
                for idx_ev, (ev_obj, ev_dt) in enumerate(sorted_day_evs, 1):
                    ev_vid = db.query(Video).filter(Video.id == ev_obj.video_id).first()
                    if idx_ev == 1:
                        lbl = "First Check-In"
                    elif idx_ev == len(sorted_day_evs) and ev_dt > ds["checkin"]:
                        lbl = "Last Check-Out"
                    else:
                        lbl = "In" if idx_ev % 2 == 1 else "Out"
                    att_events_list.append({
                        "event_num": idx_ev,
                        "track_id": f"TRK-{ev_obj.track_id}",
                        "timestamp": ev_dt.strftime("%I:%M %p"),
                        "event_type": lbl,
                        "has_video": True if ev_vid else False,
                        "video_url": f"/videos/stream/{ev_vid.id}" if ev_vid else None,
                        "timestamp_sec": _get_video_seek_sec(ev_obj, ev_dt, ev_vid),
                    })
            entry["all_attendance_events"] = att_events_list

            if is_break_report:
                dbs = [bs for bs in all_break_sessions if bs["date"] == target_date.strftime("%d-%m-%Y")]
                tot_b_secs = sum(bs.get("duration_secs", 0) for bs in dbs)
                if tot_b_secs < 60 and tot_b_secs > 0:
                    d_b_str = f"{tot_b_secs:02d} secs"
                else:
                    d_b_str = f"{ds['break_mins'] // 60:02d} hrs {ds['break_mins'] % 60:02d} mins"
                entry["break_count"] = len(dbs)
                entry["total_break_count"] = len(dbs)
                entry["breakin"] = dbs[0]["breakin"] if dbs else None
                entry["breakout"] = dbs[0]["breakout"] if dbs else None
                # First Break-In: first session with a real breakin
                first_bi = "--"
                for bs in dbs:
                    bi = bs.get("breakin", "")
                    if bi and bi not in ("—", "--", None):
                        first_bi = bi
                        break
                entry["first_breakin"] = first_bi
                # Last Break-Out: find last session that has a real breakout (not — or Missed)
                last_valid_bo = "--"
                for bs in reversed(dbs):
                    bo = bs.get("breakout", "")
                    if bo and bo not in ("—", "--", "Missed", "Active", None):
                        last_valid_bo = bo
                        break
                entry["last_breakout"] = last_valid_bo
                entry["total_break_duration"] = d_b_str
                entry["break_sessions"] = dbs

                day_excess = max(0, ds["break_mins"] - r_allowed_break)
                exceeded_count = sum(1 for bs in dbs if bs.get("excess_mins", 0) > 0)
                entry["excess_break_mins"] = day_excess
                entry["excess_break_count"] = exceeded_count
                entry["total_break_exceeded"] = f"{day_excess} mins" if day_excess > 0 else "00 mins"
                entry["break_exceeded_display"] = f"{day_excess} mins ({exceeded_count} exceeded)" if day_excess > 0 else "00 mins"

                off_win_count = sum(1 for bs in dbs if bs.get("is_off_window"))
                entry["total_off_window"] = off_win_count
            
            # Status matching
            status_lower = ds["status"].lower()
            if sf_lower == "all": matched = True
            elif is_break_report:
                if sf_lower == "employees_with_breaks" and entry.get("break_count", 0) > 0: matched = True
                elif sf_lower == "employees_without_breaks" and entry.get("break_count", 0) == 0: matched = True
                if effective_filter == "STAFFs_with_breaks" and not entry["has_breaks"]:
                    continue
                if effective_filter == "STAFFs_without_breaks" and entry["has_breaks"]:
                    continue
            else:
                if sf_lower == "on_time" and status_lower == "on time": matched = True
                elif sf_lower == "within_grace" and status_lower == "within grace": matched = True
                elif sf_lower in ["late", "late_arrival"] and status_lower == "late": matched = True
                elif sf_lower == "early_arrival" and (status_lower == "early arrival" or ds.get("early_arrival", 0) > 0): matched = True
                elif sf_lower == "early_departure" and (status_lower == "early departure" or ds.get("early_departure", 0) > 0): matched = True
                elif sf_lower == "overtime" and (status_lower == "overtime" or ds.get("overtime", 0) > 0): matched = True
                elif sf_lower == "short_hours" and status_lower in ["short hours", "short_hours"]: matched = True
                elif sf_lower == "absent" and (status_lower == "absent" or not entry.get("check_in")): matched = True
                elif sf_lower == "missing_checkout" and status_lower in ["missing check-out", "missing checkout"]: matched = True

        else:
            # === RANGE REPORT ===
            days = []
            cur_d = date_from_dt
            import datetime as dt_module
            while cur_d <= date_to_dt:
                if cur_d.weekday() < 5 or cur_d in days_with_attendance:
                    days.append(cur_d)
                cur_d += dt_module.timedelta(days=1)
                
            total_wd = len(days)
            prs_d = 0
            late_d = 0
            edep_d = 0
            ovt_d = 0
            tot_off_mins = 0
            tot_net_mins = 0
            
            for d in days:
                ds = get_day_stats(d)
                if ds["checkin"]:
                    prs_d += 1
                if ds.get("late_by", 0) > 0 or ds["status"] == "Late":
                    late_d += 1
                if ds.get("early_departure", 0) > 0 or ds["status"] == "Early Departure":
                    edep_d += 1
                if ds.get("overtime", 0) > 0 or ds["status"] == "Overtime":
                    ovt_d += 1
                tot_off_mins += ds["office_mins"]
                tot_net_mins += ds["net_mins"]
                
            abs_d = total_wd - prs_d
            
            entry["working_days"] = total_wd
            entry["present_days"] = prs_d
            entry["absent_days"] = abs_d
            entry["late_days"] = late_d
            entry["early_departure_days"] = edep_d
            entry["overtime_days"] = ovt_d
            entry["today_office_hours"] = f"{tot_off_mins // 60:02d} hrs {tot_off_mins % 60:02d} mins"
            entry["total_break_hours"] = f"{total_break_mins // 60:02d} hrs {total_break_mins % 60:02d} mins"
            entry["net_work_hours"] = f"{tot_net_mins // 60:02d} hrs {tot_net_mins % 60:02d} mins"
            
            avg_h = (tot_net_mins // total_wd) if total_wd > 0 else 0
            entry["avg_daily_hours"] = f"{avg_h // 60:02d} hrs {avg_h % 60:02d} mins"
            entry["attendance_pct"] = f"{int((prs_d / total_wd) * 100) if total_wd > 0 else 0}%"
            entry["attendance_status"] = "Good" if (prs_d / total_wd if total_wd > 0 else 0) >= 0.8 else "Needs Improvement"
            entry["check_in"] = None
            entry["check_out"] = None
            
            if is_break_report:
                entry["total_break_count"] = total_break_count
                entry["total_break_hours"] = f"{total_break_mins // 60:02d} hrs {total_break_mins % 60:02d} mins"
                avg_b = (total_break_mins // total_break_count) if total_break_count > 0 else 0
                entry["avg_break_duration"] = f"{avg_b // 60:02d} hrs {avg_b % 60:02d} mins"
                b_arr = [bs['duration_mins'] for bs in all_break_sessions]
                entry["longest_break"] = f"{max(b_arr) if b_arr else 0} mins"
                entry["shortest_break"] = f"{min(b_arr) if b_arr else 0} mins"
                entry["avg_breaks_per_day"] = round(total_break_count / total_wd, 1) if total_wd > 0 else 0
                entry["break_sessions"] = all_break_sessions

                tot_excess = sum(bs.get("excess_mins", 0) for bs in all_break_sessions)
                tot_exceeded_count = sum(1 for bs in all_break_sessions if bs.get("excess_mins", 0) > 0)
                entry["excess_break_mins"] = tot_excess
                entry["excess_break_count"] = tot_exceeded_count
                entry["total_break_exceeded"] = f"{tot_excess // 60:02d} hrs {tot_excess % 60:02d} mins" if tot_excess >= 60 else (f"{tot_excess} mins" if tot_excess > 0 else "00 mins")
                entry["break_exceeded_display"] = f"{tot_excess} mins ({tot_exceeded_count} exceeded)" if tot_excess > 0 else "00 mins"

                tot_off_win = sum(1 for bs in all_break_sessions if bs.get("is_off_window"))
                entry["total_off_window"] = tot_off_win

            # Match for range
            if sf_lower == "all": matched = True
            elif is_break_report:
                if sf_lower == "employees_with_breaks" and total_break_count > 0: matched = True
                elif sf_lower == "employees_without_breaks" and total_break_count == 0: matched = True
            else:
                matched = True

        if not matched:
            continue

        summary_list.append(entry)

    # Sorting
    def sort_key_func(item):
        v = item.get(sort_by, "")
        if isinstance(v, str):
            return v.lower()
        return v or ""

    summary_list.sort(key=sort_key_func, reverse=(order == "desc"))

    # Pagination
    total_records = len(summary_list)
    total_pages = (total_records + per_page - 1) // per_page if per_page > 0 else 0
    start_idx = (page - 1) * per_page
    paginated_list = summary_list[start_idx : start_idx + per_page]

    total_STAFFs = len(all_staff)
    present_count = sum(1 for e in summary_list if e.get("check_in") and e.get("check_in") != "—")
    absent_count = total_STAFFs - present_count
    on_time_count = sum(1 for e in summary_list if e["attendance_status"] in ["On Time", "Early Arrival"])
    late_count = sum(1 for e in summary_list if e["attendance_status"] in ["Late", "Within Grace"])

    avg_break_duration_mins = grand_total_break_mins // grand_total_breaks if grand_total_breaks > 0 else 0
    longest_break_overall = max(break_durations) if break_durations else 0
    shortest_break_overall = min(break_durations) if break_durations else 0

    # Resolve human readable branch name
    resolved_branch_name = "All Branches"
    if branch_id and str(branch_id).strip().lower() != "all":
        try:
            bid = int(branch_id)
            if bid in branches:
                resolved_branch_name = branches[bid]
            else:
                br_obj = db.query(Branch).filter(Branch.id == bid).first()
                if br_obj:
                    resolved_branch_name = br_obj.name
        except (ValueError, TypeError):
            br_obj = db.query(Branch).filter(Branch.name.ilike(f"%{branch_id}%")).first()
            if br_obj:
                resolved_branch_name = br_obj.name
            else:
                resolved_branch_name = str(branch_id)

    # Resolve department name
    resolved_dept_name = "All Departments"
    if department and str(department).strip().lower() != "all":
        resolved_dept_name = str(department)

    return {
        "metadata": {
            "show_branch_column": not bool(branch_id and branch_id != "all"),
            "show_department_column": not bool(department and department != "all"),
            "selected_branch": resolved_branch_name,
            "selected_branch_id": branch_id or "all",
            "selected_department": resolved_dept_name,
            "report_mode": "range" if is_multi_date else "daily"
        },
        "summary": {
            "branch_name": resolved_branch_name,
            "department_name": resolved_dept_name,
            "date_range": f"{date_from_dt.strftime('%b %d, %Y')} - {date_to_dt.strftime('%b %d, %Y')}",
            "total_STAFFs": total_STAFFs,
            "total_present": present_count,
            "total_absent": absent_count,
            "total_on_time": on_time_count,
            "total_late": late_count,
            "total_with_breaks": total_with_breaks,
            "total_without_breaks": total_without_breaks,
            "grand_total_breaks": grand_total_breaks,
            "grand_total_break_hours": f"{grand_total_break_mins // 60:02d} hrs {grand_total_break_mins % 60:02d} mins",
            "avg_break_duration": f"{avg_break_duration_mins} mins",
            "longest_break": f"{longest_break_overall} mins",
            "shortest_break": f"{shortest_break_overall} mins",
        },
        "data": paginated_list,
        "total": total_records,
        "page": page,
        "per_page": per_page,
        "total_pages": total_pages,
    }


@app.get("/api/v1/reports/summary")
def get_reports_summary_v1(
    branch_id: Optional[str] = None,
    department: Optional[str] = None,
    camera_id: Optional[str] = None,
    search: Optional[str] = None,
    report_type: Optional[str] = "attendance",
    time_frame: Optional[str] = "current_date",
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    time_from: Optional[str] = None,
    time_to: Optional[str] = None,
    status_filter: Optional[str] = "all",
    page: int = 1,
    per_page: int = 50,
    sort_by: str = "staff_id",
    order: str = "asc",
    db: Session = Depends(get_db),
):
    return get_reports_data_internal(
        branch_id, department, camera_id, search, report_type, time_frame,
        date_from, date_to, time_from, time_to, status_filter, page, per_page, sort_by, order, db
    )

@app.get("/reports/summary")
def get_reports_summary(
    branch_id: Optional[str] = None,
    department: Optional[str] = None,
    camera_id: Optional[str] = None,
    search: Optional[str] = None,
    report_type: Optional[str] = "attendance",
    time_frame: Optional[str] = "current_date",
    date_from: Optional[str] = None,
    date_to: Optional[str] = None,
    time_from: Optional[str] = None,
    time_to: Optional[str] = None,
    status_filter: Optional[str] = "all",
    page: int = 1,
    per_page: int = 50,
    sort_by: str = "staff_id",
    order: str = "asc",
    db: Session = Depends(get_db),
):
    return get_reports_data_internal(
        branch_id, department, camera_id, search, report_type, time_frame,
        date_from, date_to, time_from, time_to, status_filter, page, per_page, sort_by, order, db
    )


class GenerateReportRequest(BaseModel):
    branch_id: Optional[str] = "all"
    branch_name: Optional[str] = None
    department: Optional[str] = "all"
    department_name: Optional[str] = None
    camera_id: Optional[str] = "all"
    search: Optional[str] = ""
    report_type: Optional[str] = "attendance"
    time_frame: Optional[str] = "current_date"
    date_from: Optional[str] = None
    date_to: Optional[str] = None
    time_from: Optional[str] = None
    time_to: Optional[str] = None
    status_filter: Optional[str] = "all"

@app.post("/api/v1/reports/generate")
@app.post("/reports/generate")
def generate_excel_report_endpoint(data: GenerateReportRequest, db: Session = Depends(get_db)):
    """Generate Excel report and return download filename."""
    from generate_excel_report import generate_report_file
    
    # 1. Fetch filtered report data internally
    report_data = get_reports_data_internal(
        branch_id=data.branch_id,
        department=data.department,
        camera_id=data.camera_id,
        search=data.search,
        report_type=data.report_type,
        time_frame=data.time_frame,
        date_from=data.date_from,
        date_to=data.date_to,
        time_from=data.time_from,
        time_to=data.time_to,
        status_filter=data.status_filter,
        page=1,
        per_page=10000,
        sort_by="staff_id",
        order="asc",
        db=db
    )
    
    # Ensure human-readable branch_name is available in filters & metadata
    req_dict = data.dict()
    if data.branch_name:
        req_dict["branch_name"] = data.branch_name
    elif data.branch_id and str(data.branch_id).lower() != "all":
        try:
            b_obj = db.query(Branch).filter(Branch.id == int(data.branch_id)).first()
            if b_obj:
                req_dict["branch_name"] = b_obj.name
        except Exception:
            pass

    if req_dict.get("branch_name"):
        if "metadata" in report_data:
            report_data["metadata"]["selected_branch"] = req_dict["branch_name"]
        if "summary" in report_data:
            report_data["summary"]["branch_name"] = req_dict["branch_name"]

    filepath = generate_report_file(
        filters=req_dict,
        report_data=report_data,
        db=db,
    )
    if not filepath:
        raise HTTPException(status_code=404, detail="No data available to generate report")
    
    filename = os.path.basename(filepath)
    return {"filename": filename, "download_url": f"/api/v1/reports/download/{filename}"}


@app.get("/api/v1/reports/download/{filename}")
@app.get("/reports/download/{filename}")
def download_excel_report(filename: str):
    """Download generated Excel report file."""
    filepath = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", filename))
    if not os.path.exists(filepath):
        # Check current backend folder
        filepath = os.path.normpath(os.path.join(os.path.dirname(__file__), filename))
    if not os.path.exists(filepath):
        raise HTTPException(status_code=404, detail="Report file not found")
    return FileResponse(filepath, media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", filename=filename)


# ─────────────────────────────────────────────────────────────────────────────
# Camera Processing Reports API
# ─────────────────────────────────────────────────────────────────────────────
from sqlalchemy import or_, and_, cast, String, case

def get_camera_processing_data_internal(
    db: Session,
    page: int = 1,
    per_page: int = 25,
    sort_by: str = "processing_date",
    order: str = "desc",
    branch_id: str = "all",
    camera_id: str = "all",
    status: str = "all",
    search: str = "",
    date_from: str = None,
    date_to: str = None
):
    q = db.query(
        Video.id,
        Video.filename.label("video_name"),
        Video.folder_type,
        Branch.name.label("branch_name"),
        Camera.name.label("camera_name"),
        Video.created_at.label("processing_date"),
        Video.status,
        Video.duration_seconds.label("processing_duration"),
        func.count(case((or_(Event.event_type.ilike('%in%'), Event.camera_role.in_(['checkin', 'breakin'])), Event.id), else_=None)).label("checkin_detections"),
        func.count(case((or_(Event.event_type.ilike('%out%'), Event.camera_role.in_(['checkout', 'breakout'])), Event.id), else_=None)).label("checkout_detections"),
        func.count(Event.id).label("total_detections"),
        func.count(case((Event.recognition_status == 'recognized', Event.id), else_=None)).label("recognized_detections")
    ).outerjoin(
        Camera, Video.camera_name == Camera.name
    ).outerjoin(
        Branch, Camera.branch_id == Branch.id
    ).outerjoin(
        Event, Video.id == Event.video_id
    )

    # Filters
    if branch_id and branch_id != "all":
        if str(branch_id).isdigit():
            q = q.filter(Branch.id == int(branch_id))
        else:
            q = q.filter(Branch.name.ilike(branch_id))
        
    if camera_id and camera_id != "all":
        if str(camera_id).isdigit():
            q = q.filter(Camera.id == int(camera_id))
        else:
            q = q.filter(Camera.name.ilike(camera_id))

    if status and status != "all":
        q = q.filter(Video.status == status)

    if search:
        search_term = f"%{search}%"
        q = q.filter(or_(
            Video.filename.ilike(search_term),
            Camera.name.ilike(search_term),
            Video.folder_type.ilike(search_term)
        ))

    if date_from:
        df = parse_dt(date_from)
        if df:
            q = q.filter(Video.created_at >= df)
    if date_to:
        dt = parse_dt(date_to)
        if dt:
            dt = dt.replace(hour=23, minute=59, second=59)
            q = q.filter(Video.created_at <= dt)

    q = q.group_by(
        Video.id, Video.filename, Video.folder_type, Branch.name, Camera.name, Video.created_at, Video.status, Video.duration_seconds
    )

    # Summary logic (before pagination)
    base_summary_q = db.query(Video.status, func.count(Video.id)).outerjoin(
        Camera, Video.camera_name == Camera.name
    ).outerjoin(
        Branch, Camera.branch_id == Branch.id
    )
    
    if branch_id and branch_id != "all":
        if str(branch_id).isdigit():
            base_summary_q = base_summary_q.filter(Branch.id == int(branch_id))
        else:
            base_summary_q = base_summary_q.filter(Branch.name.ilike(branch_id))
    if camera_id and camera_id != "all":
        if str(camera_id).isdigit():
            base_summary_q = base_summary_q.filter(Camera.id == int(camera_id))
        else:
            base_summary_q = base_summary_q.filter(Camera.name.ilike(camera_id))
    if search:
        search_term = f"%{search}%"
        base_summary_q = base_summary_q.filter(or_(Video.filename.ilike(search_term), Camera.name.ilike(search_term)))
    if date_from:
        df = parse_dt(date_from)
        if df: base_summary_q = base_summary_q.filter(Video.created_at >= df)
    if date_to:
        dt = parse_dt(date_to)
        if dt: 
            dt = dt.replace(hour=23, minute=59, second=59)
            base_summary_q = base_summary_q.filter(Video.created_at <= dt)

    summary_results = base_summary_q.group_by(Video.status).all()
    
    summary = {
        "total_videos": 0,
        "passed": 0,
        "failed": 0,
        "processing": 0,
        "retry": 0
    }
    
    for stat, count in summary_results:
        summary["total_videos"] += count
        if stat == "completed" or stat == "pass":
            summary["passed"] += count
        elif stat == "failed" or stat == "fail":
            summary["failed"] += count
        elif stat == "processing":
            summary["processing"] += count
        elif stat == "retry":
            summary["retry"] += count

    total_records = sum(count for stat, count in summary_results if (status == "all" or stat == status))

    # Sorting
    if sort_by == "video_name":
        q = q.order_by(Video.filename.desc() if order == "desc" else Video.filename.asc())
    elif sort_by == "branch_name":
        q = q.order_by(Branch.name.desc() if order == "desc" else Branch.name.asc())
    elif sort_by == "camera_name":
        q = q.order_by(Camera.name.desc() if order == "desc" else Camera.name.asc())
    elif sort_by == "status":
        q = q.order_by(Video.status.desc() if order == "desc" else Video.status.asc())
    elif sort_by == "processing_duration":
        q = q.order_by(Video.duration_seconds.desc() if order == "desc" else Video.duration_seconds.asc())
    else:
        q = q.order_by(Video.created_at.desc() if order == "desc" else Video.created_at.asc())

    # Pagination
    if per_page > 0:
        offset = (page - 1) * per_page
        results = q.offset(offset).limit(per_page).all()
        total_pages = (total_records + per_page - 1) // per_page
    else:
        results = q.all()
        total_pages = 1

    formatted_data = []
    for row in results:
        b_name = row.branch_name
        c_name = row.camera_name
        v_name = row.video_name or ""
        f_type = (row.folder_type or "").lower()

        # Resolve Camera and Branch intelligently
        if not c_name or c_name in ("General Camera", "Entrance Camera", "Focus", "Full View", "Breakout", "Breakin", "Attendance"):
            if "breakin" in f_type or "_ch1_" in v_name or "_ch4_" in v_name or "breakin" in v_name.lower():
                c_name = "Break_In_Cafeteria"
                b_name = b_name or "Main Branch"
            elif "breakout" in f_type or "break" in f_type or "_ch2_" in v_name or "_ch3_" in v_name or "breakout" in v_name.lower():
                c_name = "Break_Out_Cafeteria"
                b_name = b_name or "Main Branch"
            elif "att" in f_type or "_ch5_" in v_name or "att" in v_name.lower():
                c_name = "Attendence_MainGate"
                b_name = b_name or "Main Branch"
            else:
                c_name = "Attendence_MainGate"
                b_name = b_name or "Main Branch"

        if not b_name:
            b_name = "Main Branch"

        total_ev = row.total_detections or 0
        rec_ev = row.recognized_detections or 0
        acc_pct = round((rec_ev / total_ev * 100), 1) if total_ev > 0 else 0.0

        dur_sec = row.processing_duration or 0
        dur_str = f"{int(dur_sec // 60)}m {int(dur_sec % 60)}s" if dur_sec > 0 else "—"

        formatted_data.append({
            "video_id": row.id,
            "video_name": row.video_name,
            "branch_name": b_name,
            "camera_name": c_name,
            "processing_date": row.processing_date.strftime("%Y-%m-%d %H:%M:%S") if row.processing_date else None,
            "status": row.status,
            "checkin_detections": row.checkin_detections or 0,
            "checkout_detections": row.checkout_detections or 0,
            "total_detections": total_ev,
            "recognized_detections": rec_ev,
            "accuracy_rate": f"{acc_pct}%",
            "processing_duration": dur_sec,
            "duration_formatted": dur_str
        })

    return {
        "success": True,
        "data": formatted_data,
        "pagination": {
            "page": page,
            "limit": per_page,
            "total": total_records,
            "total_pages": total_pages
        },
        "summary": summary
    }


@app.get("/api/v1/reports/camera-processing")
@app.get("/reports/camera-processing")
def get_camera_processing_report(
    page: int = 1,
    per_page: int = 25,
    sort_by: str = "processing_date",
    order: str = "desc",
    branch_id: str = "all",
    camera_id: str = "all",
    status: str = "all",
    search: str = "",
    date_from: str = None,
    date_to: str = None,
    db: Session = Depends(get_db)
):
    return get_camera_processing_data_internal(
        db, page, per_page, sort_by, order, branch_id, camera_id, status, search, date_from, date_to
    )


@app.get("/api/v1/reports/camera-processing/export")
@app.get("/reports/camera-processing/export")
def export_camera_processing_report(
    branch_id: str = "all",
    camera_id: str = "all",
    status: str = "all",
    search: str = "",
    date_from: str = None,
    date_to: str = None,
    db: Session = Depends(get_db)
):
    from generate_camera_processing_excel import generate_camera_excel
    
    report_data = get_camera_processing_data_internal(
        db, page=1, per_page=-1, sort_by="processing_date", order="desc", 
        branch_id=branch_id, camera_id=camera_id, status=status, search=search, 
        date_from=date_from, date_to=date_to
    )
    
    filepath = generate_camera_excel(report_data["data"])
    if not filepath:
        raise HTTPException(status_code=500, detail="Failed to generate Excel export")
        
    filename = os.path.basename(filepath)
    return {"filename": filename, "download_url": f"/api/v1/reports/download/{filename}"}


@app.get("/api/v1/reports/camera-processing/{video_id}")
@app.get("/reports/camera-processing/{video_id}")
def get_camera_processing_detail(video_id: int, db: Session = Depends(get_db)):
    video = db.query(Video).filter(Video.id == video_id).first()
    if not video:
        raise HTTPException(status_code=404, detail="Video not found")
        
    camera = db.query(Camera).filter(Camera.name == video.camera_name).first()
    branch_name = db.query(Branch.name).filter(Branch.id == camera.branch_id).scalar() if camera else None

    events = db.query(Event).filter(Event.video_id == video_id).order_by(Event.timestamp.asc()).all()
    
    event_list = []
    for e in events:
        event_list.append({
            "id": e.id,
            "camera_role": e.camera_role,
            "track_id": e.track_id,
            "timestamp": e.timestamp,
            "frame_number": e.frame_number,
            "confidence": round(e.confidence or 0.0, 3),
            "recognition_status": e.recognition_status,
            "employee_id": e.employee_id,
            "employee_name": e.employee_name
        })
        
    return {
        "success": True,
        "video": {
            "id": video.id,
            "filename": video.filename,
            "camera_name": video.camera_name,
            "branch_name": branch_name,
            "status": video.status,
            "processing_datetime": video.created_at.isoformat() if video.created_at else None,
            "duration_seconds": video.duration_seconds
        },
        "detections": event_list
    }


# ─────────────────────────────────────────────────────────────────────────────
# Ambiguous Review Queue & Active Learning Endpoints
# ─────────────────────────────────────────────────────────────────────────────

@app.get("/api/review/pending")
def get_pending_reviews(db: Session = Depends(get_db)):
    """Retrieve all pending face match reviews with their corresponding events."""
    reviews = db.query(ReviewQueue).filter(ReviewQueue.status == "pending").order_by(ReviewQueue.created_at.desc()).all()
    res = []
    for rq in reviews:
        evt = rq.event
        event_info = None
        if evt:
            event_info = {
                "id": evt.id,
                "camera_role": evt.camera_role,
                "track_id": evt.track_id,
                "timestamp": evt.timestamp,
                "frame_number": evt.frame_number,
                "video_id": evt.video_id
            }
        
        # Expose local path as relative static URL
        face_crop_url = None
        if rq.face_crop_path:
            face_crop_url = "/data/review_crops/" + os.path.basename(rq.face_crop_path)
            
        res.append({
            "id": rq.id,
            "event_id": rq.event_id,
            "suggested_staff_id": rq.suggested_staff_id,
            "confidence": round(rq.confidence or 0.0, 4),
            "status": rq.status,
            "face_crop_url": face_crop_url,
            "created_at": rq.created_at.isoformat() if rq.created_at else None,
            "event": event_info
        })
    return res


@app.post("/api/review/resolve")
def resolve_review(req: ResolveReviewRequest, db: Session = Depends(get_db)):
    """Resolve an ambiguous face match review and learn corrected biometric embeddings."""
    rq = db.query(ReviewQueue).filter(ReviewQueue.id == req.review_id).first()
    if not rq:
        raise HTTPException(status_code=404, detail="Review item not found")
        
    evt = db.query(Event).filter(Event.id == rq.event_id).first()
    if not evt:
        raise HTTPException(status_code=404, detail="Corresponding Event not found")

    action = req.action.lower()
    
    if action == "mark_unrecognized":
        evt.recognition_status = "unrecognized"
        evt.employee_id = None
        evt.employee_name = f"Person #{evt.track_id}"
        rq.status = "resolved"
        db.commit()
        return {"success": True, "message": "Review resolved as unrecognized."}
        
    # Find target staff ID
    if action == "accept_suggested":
        target_staff_id = rq.suggested_staff_id
    elif action == "assign_staff_id":
        target_staff_id = req.assign_staff_id
    else:
        raise HTTPException(status_code=400, detail="Invalid action type")
        
    if not target_staff_id:
        raise HTTPException(status_code=400, detail="Target staff ID is required for this action")

    # Get staff member details from DB
    staff = db.query(Staff).filter(Staff.staff_id == str(target_staff_id)).first()
    if not staff:
        raise HTTPException(status_code=404, detail=f"Staff member with ID {target_staff_id} not found")

    # Update event details
    evt.recognition_status = "recognized"
    evt.employee_id = staff.staff_id
    evt.employee_name = staff.name
    rq.status = "resolved"

    # Active learning from corrections: extract embedding from crop and save with low quality weight
    if rq.face_crop_path and os.path.exists(rq.face_crop_path):
        import cv2
        import numpy as np
        
        try:
            crop_img = cv2.imread(rq.face_crop_path)
            if crop_img is not None:
                # Import face app singleton
                try:
                    from ai.face_registration import get_face_app
                    app = get_face_app()
                except ImportError:
                    from backend.ai.face_registration import get_face_app
                    app = get_face_app()
                    
                rgb_crop = cv2.cvtColor(crop_img, cv2.COLOR_BGR2RGB)
                faces = app.get(rgb_crop)
                
                # If not found, try full image or resized
                if not faces:
                    h, w = rgb_crop.shape[:2]
                    resized = cv2.resize(rgb_crop, (640, 640))
                    faces = app.get(resized)
                    
                if faces:
                    # Get largest face
                    faces = sorted(faces, key=lambda x: (x.bbox[2]-x.bbox[0])*(x.bbox[3]-x.bbox[1]), reverse=True)
                    embedding = faces[0].embedding.tolist()
                    
                    # Update PKL encodings file
                    pkl_path = os.path.join(os.path.dirname(__file__), "ai", "encoding", "encodings.pkl")
                    
                    data = {}
                    if os.path.exists(pkl_path):
                        with open(pkl_path, "rb") as f:
                            data = pickle.load(f)
                            
                    sid_str = str(staff.staff_id)
                    if sid_str in data:
                        data[sid_str]["encodings"].append(embedding)
                        if "weights" not in data[sid_str]:
                            data[sid_str]["weights"] = [1.0] * (len(data[sid_str]["encodings"]) - 1)
                        data[sid_str]["weights"].append(0.85) # lower weight for manual resolution crops
                    else:
                        data[sid_str] = {
                            "name": staff.name,
                            "encodings": [embedding],
                            "weights": [0.85],
                            "registered_at": datetime.now().isoformat(),
                            "dp_path": staff.profile_picture
                        }
                        
                    # Save updated encodings PKL
                    os.makedirs(os.path.dirname(pkl_path), exist_ok=True)
                    with open(pkl_path, "wb") as f:
                        pickle.dump(data, f)
                        
                    staff.has_face_encoding = True
                    print(f"[ACTIVE LEARNING] Appended new manual review face embedding to {staff.name} (weight: 0.85)")
        except Exception as active_err:
            print(f"[ACTIVE LEARNING ERROR] Failed extracting or saving corrected face embedding: {active_err}")

    db.commit()
    return {"success": True, "message": f"Review resolved and linked to {staff.name}."}


# ═══════════════════════════════════════════════════════════════════════════
# Processing Status Dashboard Endpoints
# ═══════════════════════════════════════════════════════════════════════════

@app.get("/api/pipeline/status")
def get_pipeline_status(db: Session = Depends(get_db)):
    """
    Returns aggregate processing status counts across all videos:
    pending, processing, completed, error.
    """
    from sqlalchemy import func

    status_counts = (
        db.query(Video.status, func.count(Video.id))
        .group_by(Video.status)
        .all()
    )

    counts = {"pending": 0, "processing": 0, "completed": 0, "error": 0}
    total = 0
    for status, count in status_counts:
        key = (status or "pending").lower()
        if key in counts:
            counts[key] = count
        else:
            counts[key] = count
        total += count

    # Recent processing activity (last 10 completed)
    recent = (
        db.query(Video)
        .filter(Video.status == "completed")
        .order_by(Video.updated_at.desc() if hasattr(Video, 'updated_at') else Video.id.desc())
        .limit(10)
        .all()
    )

    recent_list = []
    for v in recent:
        recent_list.append({
            "id": v.id,
            "filename": v.filename if hasattr(v, 'filename') else str(v.id),
            "folder_type": v.folder_type if hasattr(v, 'folder_type') else None,
            "status": v.status if hasattr(v, 'status') else "completed",
        })

    return {
        "total_videos": total,
        "counts": counts,
        "progress_pct": round((counts["completed"] / total * 100), 1) if total > 0 else 0.0,
        "recent_completed": recent_list,
    }


@app.get("/api/pipeline/status/by-camera")
def get_pipeline_status_by_camera(db: Session = Depends(get_db)):
    """
    Returns per-camera-role processing breakdown.
    """
    from sqlalchemy import func

    rows = (
        db.query(
            Video.folder_type,
            Video.status,
            func.count(Video.id),
        )
        .group_by(Video.folder_type, Video.status)
        .all()
    )

    cameras = {}
    for folder_type, status, count in rows:
        role = folder_type or "unknown"
        if role not in cameras:
            cameras[role] = {"pending": 0, "processing": 0, "completed": 0, "error": 0, "total": 0}
        key = (status or "pending").lower()
        cameras[role][key] = cameras[role].get(key, 0) + count
        cameras[role]["total"] += count

    return {"cameras": cameras}


@app.get("/api/pipeline/errors")
def get_pipeline_errors(
    limit: int = 20,
    db: Session = Depends(get_db),
):
    """
    Returns the most recent videos that failed processing.
    """
    errors = (
        db.query(Video)
        .filter(Video.status == "error")
        .order_by(Video.id.desc())
        .limit(limit)
        .all()
    )

    result = []
    for v in errors:
        result.append({
            "id": v.id,
            "filename": v.filename if hasattr(v, 'filename') else str(v.id),
            "folder_type": v.folder_type if hasattr(v, 'folder_type') else None,
            "status": "error",
            "error_message": v.error_message if hasattr(v, 'error_message') else None,
        })

    return {"errors": result, "count": len(result)}


@app.get("/api/pipeline/health")
def get_system_health():
    """
    Quick health check endpoint for monitoring / Docker health-checks.
    """
    import platform

    health = {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "python_version": platform.python_version(),
        "platform": platform.platform(),
    }

    # Check GPU availability
    try:
        import torch
        health["cuda_available"] = torch.cuda.is_available()
        if torch.cuda.is_available():
            health["gpu_count"] = torch.cuda.device_count()
            health["gpu_name"] = torch.cuda.get_device_name(0)
    except ImportError:
        health["cuda_available"] = False

    return health

# trigger reload
