from typing import Optional, Dict, Any, List
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey, Boolean, Table, UniqueConstraint
from sqlalchemy.orm import declarative_base, sessionmaker, relationship, synonym
from datetime import datetime

import os



# Environment variable configuration with automatic .env loading

DB_DIR = os.path.dirname(os.path.abspath(__file__))



# Load .env file automatically

def _load_env_file():

    possible_paths = [

        os.path.join(DB_DIR, "..", ".env"),

        os.path.join(DB_DIR, "..", "backend", ".env"),

        os.path.join(os.getcwd(), ".env"),

    ]

    for env_path in possible_paths:

        if os.path.exists(env_path):

            try:

                with open(env_path, "r", encoding="utf-8") as f:

                    for line in f:

                        line = line.strip()

                        if line and not line.startswith("#") and "=" in line:

                            key, value = line.split("=", 1)

                            key = key.strip()

                            value = value.strip().strip("'").strip('"')

                            if key not in os.environ:

                                os.environ[key] = value

            except Exception:

                pass



_load_env_file()



postgres_user = os.getenv("POSTGRES_USER", "postgres")

postgres_password = os.getenv("POSTGRES_PASSWORD", "1234")

postgres_host = os.getenv("POSTGRES_HOST", "localhost")

postgres_port = os.getenv("POSTGRES_PORT", "5432")

postgres_db = os.getenv("POSTGRES_DB", "epic_surveillance")



try:
    from config.settings import cfg as _cfg
    _config_db_url = _cfg.get("database", {}).get("url")
except Exception:
    _config_db_url = None

if os.getenv("DATABASE_URL"):
    DATABASE_URL = os.getenv("DATABASE_URL")
elif _config_db_url:
    DATABASE_URL = _config_db_url
else:
    DATABASE_URL = f"postgresql://{postgres_user}:{postgres_password}@{postgres_host}:{postgres_port}/{postgres_db}"



connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    pool_size=30,
    max_overflow=50,
    pool_timeout=60,
    pool_recycle=1800,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)



Base = declarative_base()





# Junction Table for Many-to-Many relationship between Role and Permission

role_permissions = Table(

    "role_permissions",

    Base.metadata,

    Column("role_id", Integer, ForeignKey("roles.id", ondelete="CASCADE"), primary_key=True),

    Column("permission_id", Integer, ForeignKey("permissions.id", ondelete="CASCADE"), primary_key=True)

)





class Department(Base):

    """

    EPIC Organizational Departments - organizational divisions for staff and users.

    """

    __tablename__ = "departments"



    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, unique=True, index=True, nullable=False)

    description = Column(String, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Shift Settings

    shift_name = Column(String, default="Morning")

    shift_start = Column(String, default="09:00")

    shift_end = Column(String, default="17:00")

    grace_time_mins = Column(Integer, default=15)

    early_departure_buffer_mins = Column(Integer, default=10)

    break_start = Column(String, default="13:00")

    break_end = Column(String, default="14:00")



    branch_id = Column(Integer, ForeignKey("branches.id"), nullable=True)

    # Relationships

    users = relationship("User", back_populates="department")

    staff = relationship("Staff", back_populates="department")

    branch = relationship("Branch", back_populates="departments")

    shifts = relationship("Shift", back_populates="department", cascade="all, delete-orphan")





class Shift(Base):

    """

    EPIC Department Shifts - multiple shifts assigned to a department.

    """

    __tablename__ = "department_shifts"



    id = Column(Integer, primary_key=True, index=True)

    department_id = Column(Integer, ForeignKey("departments.id", ondelete="CASCADE"), nullable=False)

    shift_name = Column(String, default="Morning")

    shift_start = Column(String, default="09:00")

    shift_end = Column(String, default="17:00")

    grace_time_mins = Column(Integer, default=15)

    early_departure_buffer_mins = Column(Integer, default=10)

    break_start = Column(String, default="13:00")

    break_end = Column(String, default="14:00")

    days = Column(String, default="Mon,Tue,Wed,Thu,Fri")



    # Relationship

    department = relationship("Department", back_populates="shifts")





class Permission(Base):

    """

    EPIC Permissions - individual actions that can be authorized.

    """

    __tablename__ = "permissions"



    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, unique=True, index=True, nullable=False)  # e.g. "create_staff"

    description = Column(String, nullable=True)

    group = Column(String, nullable=False)  # Category for frontend grouping (e.g. "Staff Management")





class Role(Base):

    """

    EPIC Roles - custom roles configured by administrators.

    """

    __tablename__ = "roles"



    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, unique=True, index=True, nullable=False)

    is_active = Column(Boolean, default=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)



    # Relationships

    permissions = relationship("Permission", secondary=role_permissions, backref="roles")

    users = relationship("User", back_populates="assigned_role")





class User(Base):

    """

    EPIC System Users - stores login credentials for dashboard access.

    Passwords are stored as bcrypt hashes (never plaintext).

    """

    __tablename__ = "users"



    id = Column(Integer, primary_key=True, index=True)

    username = Column(String, unique=True, index=True, nullable=False)

    email = Column(String, unique=True, index=True, nullable=False)

    hashed_password = Column(String, nullable=False)

    full_name = Column(String, nullable=True)

    role = Column(String, default="viewer")  # Admin / Viewer string for compatibility

    role_id = Column(Integer, ForeignKey("roles.id"), nullable=True)

    department_id = Column(Integer, ForeignKey("departments.id"), nullable=True)

    is_active = Column(Boolean, default=True)

    is_super_admin = Column(Boolean, default=False)
    is_first_login = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    last_login = Column(DateTime, nullable=True)
    reset_token = Column(String, nullable=True)

    # Relationships

    assigned_role = relationship("Role", back_populates="users")

    department = relationship("Department", back_populates="users")





class Branch(Base):

    """

    EPIC Organizational Branches - physical locations / sites with assigned cameras and staff.

    """

    __tablename__ = "branches"



    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, unique=True, index=True, nullable=False)

    address = Column(String, nullable=True)

    phone = Column(String, nullable=True)

    manager_name = Column(String, nullable=True)

    status = Column(String, default="active") # active / inactive

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    cameras = relationship("Camera", back_populates="branch", cascade="all, delete-orphan")
    staff = relationship("Staff", back_populates="branch", cascade="all, delete-orphan")
    departments = relationship("Department", back_populates="branch")
    activities = relationship("BranchActivity", back_populates="branch", cascade="all, delete-orphan")


class Activity(Base):
    """
    Global Activities Master Library (e.g. Attendance, Break, Inspection, etc.)
    that users can define and assign to Branches.
    """
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    activity_id = Column(String, unique=True, index=True, nullable=False)  # e.g. ACT-001, ACT-002
    name = Column(String, nullable=False, unique=True)  # e.g. Attendance, Break
    description = Column(String, nullable=True)
    types = Column(String, nullable=True)  # JSON list of types/places
    status = Column(String, default="active")  # active / inactive
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class BranchActivity(Base):
    """
    Branch Activities (e.g. Attendance, Break, Meeting, Shift, etc.) configured per branch.
    """
    __tablename__ = "branch_activities"

    id = Column(Integer, primary_key=True, index=True)
    branch_id = Column(Integer, ForeignKey("branches.id", ondelete="CASCADE"), nullable=False, index=True)
    activity_id = Column(String, nullable=False, index=True)  # From global activities or entered e.g. ACT-001
    name = Column(String, nullable=False)  # User entered e.g. Attendance, Break
    floor = Column(String, nullable=True)  # Floor/Type e.g. Ground Floor, 1st Floor, Custom Floor
    camera_direction = Column(String, nullable=True)  # In / Out / Bi-directional
    camera_id = Column(String, nullable=True)  # Primary assigned Camera ID e.g. CAM-001
    camera_name = Column(String, nullable=True)  # Primary assigned Camera Name
    camera_ids = Column(String, nullable=True)  # Comma-separated or JSON list of assigned camera IDs
    description = Column(String, nullable=True)
    status = Column(String, default="active")  # active / inactive
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    branch = relationship("Branch", back_populates="activities")







class Staff(Base):

    """

    EPIC Staff Members - STAFFs assigned to branches.

    """

    __tablename__ = "staff"



    id = Column(Integer, primary_key=True, index=True)

    staff_id = Column(String, unique=True, index=True, nullable=False)

    name = Column(String, nullable=False)

    email = Column(String, unique=True, index=True, nullable=False)

    phone = Column(String, nullable=True)

    role = Column(String, default="STAFF")
    is_active = Column(Boolean, default=True)
    has_face_encoding = Column(Boolean, default=False)

    profile_picture = Column(String, nullable=True)
    registration_video = Column(String, nullable=True)

    branch_id = Column(Integer, ForeignKey("branches.id"), nullable=True, index=True)

    department_id = Column(Integer, ForeignKey("departments.id"), nullable=True, index=True)

    shift_start_time = Column(String, nullable=True)

    shift_end_time = Column(String, nullable=True)

    is_visitor = Column(Boolean, default=False)

    visitor_expiry = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships

    branch = relationship("Branch", back_populates="staff")

    department = relationship("Department", back_populates="staff", foreign_keys=[department_id])







import time
import random

class Camera(Base):
    """
    CCTV Cameras assigned to specific Branches for Check-In / Check-Out offline video & RTSP processing.
    """
    __tablename__ = "cameras"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    camera_id = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    branch_id = Column(Integer, ForeignKey("branches.id"), nullable=False, index=True)
    activity_id = Column(String, nullable=True)
    activity_name = Column(String, nullable=True)
    location = Column(String, nullable=True)
    camera_type = Column(String, default="In") # In / Out
    sub_location = Column(String, nullable=True) # e.g., 'Cafeteria 1'
    rtsp_url = Column(String, nullable=True)
    recording_path = Column(String, nullable=True)
    is_checkin = Column(Boolean, default=False)
    is_checkout = Column(Boolean, default=False)
    status = Column(String, default="active") # active / inactive / online / offline
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationship back to branch
    branch = relationship("Branch", back_populates="cameras")





class Video(Base):

    __tablename__ = "videos"



    id = Column(Integer, primary_key=True, index=True)

    filename = Column(String, unique=True, index=True)

    folder_type = Column(String, index=True) # checkin or checkout

    file_path = Column(String)

    file_size_mb = Column(Float)

    duration_seconds = Column(Float)

    resolution = Column(String)

    fps = Column(Float)

    video_start_time = Column(String, nullable=True)

    camera_name = Column(String, nullable=True)

    status = Column(String, default="pending") # pending, processing, completed



    created_at = Column(DateTime, default=datetime.utcnow)



    # Relationship to events

    events = relationship("Event", back_populates="video")





class Event(Base):

    """

    Pipeline 1: Person appearance events detected via YOLO + ByteTrack.

    Pipeline 2: Face recognition results added to each event.

    """

    __tablename__ = "events"



    id = Column(Integer, primary_key=True, index=True)

    video_id = Column(Integer, ForeignKey("videos.id"), nullable=True, index=True)

    camera_role = Column(String, index=True)        # breakin / breakout

    track_id = Column(Integer, nullable=False)       # ByteTrack assigned Track ID

    event_type = Column(String, default="person_detected")

    timestamp = Column(String, nullable=True)        # Real-world timestamp

    frame_number = Column(Integer, nullable=False)   # Frame index in video

    confidence = Column(Float, nullable=True)        # Detection confidence score

    status = Column(String, default="pending_recognition")

    created_at = Column(DateTime, default=datetime.utcnow)



    # Pipeline 2: Face Recognition Results

    employee_id = Column(String, nullable=True, index=True)

    employee_name = Column(String, nullable=True)

    recognition_confidence = Column(Float, nullable=True)

    recognition_status = Column(String, default="pending")

    recognized_at = Column(DateTime, nullable=True)

    STAFF_id = synonym("employee_id")
    STAFF_name = synonym("employee_name")

    # Relationship back to video

    video = relationship("Video", back_populates="events")

    __table_args__ = (
        UniqueConstraint("video_id", "track_id", "frame_number", name="uq_events_video_track_frame"),
    )



class SystemLog(Base):

    __tablename__ = "system_logs"



    id = Column(Integer, primary_key=True, index=True)

    timestamp = Column(DateTime, default=datetime.utcnow)

    level = Column(String, default="info")

    module = Column(String, default="system")

    message = Column(String)


class VideoProcessingLog(Base):
    __tablename__ = "video_processing_logs"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    video_name = Column(String(255), nullable=False, index=True)
    video_start_timestamp = Column(String(100), nullable=True)
    total_frames_processed = Column(Integer, default=0)
    total_unique_tracks = Column(Integer, default=0)
    authorized_count = Column(Integer, default=0)
    unauthorized_count = Column(Integer, default=0)
    authorized_persons = Column(String, nullable=True)
    processed_at = Column(DateTime, default=datetime.utcnow)

    tracks = relationship("PersonTrackLog", back_populates="video_log", cascade="all, delete-orphan")


class PersonTrackLog(Base):
    __tablename__ = "person_track_logs"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    video_log_id = Column(Integer, ForeignKey("video_processing_logs.id", ondelete="CASCADE"), nullable=False)
    video_name = Column(String(255), nullable=False)
    track_id = Column(Integer, nullable=False)
    master_track_id = Column(Integer, nullable=False)
    status = Column(String(50), nullable=False)  # 'Authorized' or 'Unauthorized'
    person_name = Column(String(255), nullable=False)
    person_id = Column(String(100), nullable=True)
    confidence = Column(Float, default=0.0)
    first_seen_time = Column(String(100), nullable=True)
    last_seen_time = Column(String(100), nullable=True)
    total_hits = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

    video_log = relationship("VideoProcessingLog", back_populates="tracks")


class ReviewQueue(Base):
    __tablename__ = "review_queue"

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey("events.id", ondelete="CASCADE"), nullable=False, index=True)
    suggested_staff_id = Column(String, nullable=True)
    confidence = Column(Float, nullable=True)
    status = Column(String, default="pending")      # pending, resolved
    face_crop_path = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    event = relationship("Event")



def save_video_processing_results(results: dict) -> Optional[int]:
    """
    Saves video processing results to PostgreSQL/SQLite database across both
    video_processing_logs/person_track_logs and EPIC dashboard Video/Event tables.
    """
    import json
    db = SessionLocal()

    def _ts_or_none(value):
        """Coerce a possibly-missing timestamp value to a real string or None
        -- never the literal "N/A", which downstream timestamp parsing
        (e.g. parallel_runner.py's dedup logic) would silently misinterpret
        rather than reject."""
        return str(value) if value else None

    try:
        video_name = results.get("video_name", "unknown")
        auth_persons_json = json.dumps(results.get("authorized_persons_list", []))

        # 1. Save to video_processing_logs
        v_log = VideoProcessingLog(
            video_name=video_name,
            video_start_timestamp=_ts_or_none(results.get("video_start_timestamp")),
            total_frames_processed=results.get("total_frames_processed", 0),
            total_unique_tracks=results.get("total_unique_tracks", 0),
            authorized_count=results.get("authorized_unique_persons_count", 0),
            unauthorized_count=results.get("unauthorized_unique_persons_count", 0),
            authorized_persons=auth_persons_json,
            processed_at=datetime.utcnow()
        )
        db.add(v_log)
        db.flush()

        # 2. Save individual PersonTrackLog records
        for track in results.get("tracks", []):
            t_log = PersonTrackLog(
                video_log_id=v_log.id,
                video_name=video_name,
                track_id=track.get("track_id", 0),
                master_track_id=track.get("master_track_id", 0),
                status=track.get("status", "Unauthorized"),
                person_name=track.get("person_name", "Unknown"),
                person_id=track.get("person_id"),
                confidence=float(track.get("confidence", 0.0)),
                first_seen_time=_ts_or_none(track.get("first_seen_timestamp")),
                last_seen_time=_ts_or_none(track.get("last_seen_timestamp")),
                total_hits=track.get("total_hits", 0),
                created_at=datetime.utcnow()
            )
            db.add(t_log)

        # 3. Update/Sync EPIC Video & Event tables for web-frontend compatibility
        video_rec = db.query(Video).filter(Video.filename == video_name).first()
        if not video_rec:
            folder_type = "breakin" if "checkin" in video_name.lower() or "breakin" in video_name.lower() else "breakout"
            video_rec = Video(
                filename=video_name,
                folder_type=folder_type,
                file_path=video_name,
                status="completed",
                video_start_time=_ts_or_none(results.get("video_start_timestamp"))
            )
            db.add(video_rec)
            db.flush()
        else:
            video_rec.status = "completed"
            if results.get("video_start_timestamp"):
                video_rec.video_start_time = str(results.get("video_start_timestamp"))

        # Create Event entries for web-frontend
        for track in results.get("tracks", []):
            rec_status = "recognized" if track.get("status") == "Authorized" else "unrecognized"
            evt = Event(
                video_id=video_rec.id,
                camera_role=video_rec.folder_type,
                track_id=track.get("master_track_id", track.get("track_id", 0)),
                event_type="person_detected",
                timestamp=_ts_or_none(track.get("first_seen_timestamp")),
                frame_number=track.get("first_frame_detected", 0),
                confidence=float(track.get("confidence", 0.0)),
                status="completed",
                STAFF_id=track.get("person_id"),
                STAFF_name=track.get("person_name"),
                recognition_confidence=float(track.get("confidence", 0.0)),
                recognition_status=rec_status,
                recognized_at=datetime.utcnow()
            )
            db.add(evt)

        db.commit()
        print(f"[DATABASE SUCCESS] Saved NVDEC AI processing log (ID #{v_log.id}) with {len(results.get('tracks', []))} track records into DB.")
        return v_log.id
    except Exception as e:
        db.rollback()
        print(f"[DATABASE ERROR] Failed to save video log to database: {e}")
        return None
    finally:
        db.close()





def upgrade_db_schema():
    from sqlalchemy import inspect, text
    
    try:
        inspector = inspect(engine)
        table_names = inspector.get_table_names()
    except Exception as e:
        print(f"[Schema Upgrade] Failed to inspect database: {e}")
        return

    # 1. Upgrade users table columns
    if "users" in table_names:
        try:
            user_columns = [col["name"] for col in inspector.get_columns("users")]
            with engine.begin() as conn:
                if "hashed_password" not in user_columns:
                    if "password" in user_columns:
                        print("[Schema Upgrade] Renaming users.password to users.hashed_password...")
                        conn.execute(text("ALTER TABLE users RENAME COLUMN password TO hashed_password"))
                    else:
                        print("[Schema Upgrade] Adding users.hashed_password column...")
                        conn.execute(text("ALTER TABLE users ADD COLUMN hashed_password VARCHAR NOT NULL DEFAULT ''"))
                if "role_id" not in user_columns:
                    print("[Schema Upgrade] Adding users.role_id column...")
                    conn.execute(text("ALTER TABLE users ADD COLUMN role_id INTEGER REFERENCES roles(id)"))
                if "department_id" not in user_columns:
                    print("[Schema Upgrade] Adding users.department_id column...")
                    conn.execute(text("ALTER TABLE users ADD COLUMN department_id INTEGER REFERENCES departments(id)"))
                if "is_super_admin" not in user_columns:
                    print("[Schema Upgrade] Adding users.is_super_admin column...")
                    conn.execute(text("ALTER TABLE users ADD COLUMN is_super_admin BOOLEAN DEFAULT FALSE"))
                if "is_first_login" not in user_columns:
                    print("[Schema Upgrade] Adding users.is_first_login column...")
                    conn.execute(text("ALTER TABLE users ADD COLUMN is_first_login BOOLEAN DEFAULT TRUE"))
                if "reset_token" not in user_columns:
                    print("[Schema Upgrade] Adding users.reset_token column...")
                    conn.execute(text("ALTER TABLE users ADD COLUMN reset_token VARCHAR"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading users table: {e}")

    # 2. Upgrade staff table columns
    if "staff" in table_names:
        try:
            staff_columns = [col["name"] for col in inspector.get_columns("staff")]
            with engine.begin() as conn:
                if "department_id" not in staff_columns:
                    print("[Schema Upgrade] Adding staff.department_id column...")
                    conn.execute(text("ALTER TABLE staff ADD COLUMN department_id INTEGER REFERENCES departments(id)"))
                if "registration_video" not in staff_columns:
                    print("[Schema Upgrade] Adding staff.registration_video column...")
                    conn.execute(text("ALTER TABLE staff ADD COLUMN registration_video VARCHAR"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading staff table: {e}")

    # 3. Upgrade departments table columns
    if "departments" in table_names:
        try:
            dept_columns = [col["name"] for col in inspector.get_columns("departments")]
            with engine.begin() as conn:
                if "shift_name" not in dept_columns:
                    conn.execute(text("ALTER TABLE departments ADD COLUMN shift_name VARCHAR DEFAULT 'Morning'"))
                if "shift_start" not in dept_columns:
                    conn.execute(text("ALTER TABLE departments ADD COLUMN shift_start VARCHAR DEFAULT '09:00'"))
                if "shift_end" not in dept_columns:
                    conn.execute(text("ALTER TABLE departments ADD COLUMN shift_end VARCHAR DEFAULT '17:00'"))
                if "grace_time_mins" not in dept_columns:
                    conn.execute(text("ALTER TABLE departments ADD COLUMN grace_time_mins INTEGER DEFAULT 15"))
                if "early_departure_buffer_mins" not in dept_columns:
                    conn.execute(text("ALTER TABLE departments ADD COLUMN early_departure_buffer_mins INTEGER DEFAULT 10"))
                if "break_start" not in dept_columns:
                    conn.execute(text("ALTER TABLE departments ADD COLUMN break_start VARCHAR DEFAULT '13:00'"))
                if "break_end" not in dept_columns:
                    conn.execute(text("ALTER TABLE departments ADD COLUMN break_end VARCHAR DEFAULT '14:00'"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading departments table: {e}")

    # 4. Create department_shifts table structure if not exists, and migrate data
    # (Since create_all is called afterwards, we check/migrate shift data if table exists)
    if "department_shifts" in table_names:
        try:
            shift_columns = [col["name"] for col in inspector.get_columns("department_shifts")]
            with engine.begin() as conn:
                if "days" not in shift_columns:
                    print("[Schema Upgrade] Adding 'days' column to department_shifts...")
                    conn.execute(text("ALTER TABLE department_shifts ADD COLUMN days VARCHAR DEFAULT 'Mon,Tue,Wed,Thu,Fri'"))
                if "early_departure_buffer_mins" not in shift_columns:
                    print("[Schema Upgrade] Adding 'early_departure_buffer_mins' column to department_shifts...")
                    conn.execute(text("ALTER TABLE department_shifts ADD COLUMN early_departure_buffer_mins INTEGER DEFAULT 10"))

                # Migrate data if table is empty
                count_res = conn.execute(text("SELECT COUNT(*) FROM department_shifts")).first()
                if count_res and count_res[0] == 0:
                    print("[Schema Upgrade] Migrating single-shift configurations to department_shifts...")
                    rows = conn.execute(text("SELECT id, shift_name, shift_start, shift_end, grace_time_mins, early_departure_buffer_mins, break_start, break_end FROM departments")).fetchall()
                    for r in rows:
                        dept_id, name, start, end, grace, early_dep, b_start, b_end = r
                        conn.execute(
                            text("INSERT INTO department_shifts (department_id, shift_name, shift_start, shift_end, grace_time_mins, early_departure_buffer_mins, break_start, break_end, days) VALUES (:dept_id, :name, :start, :end, :grace, :early_dep, :b_start, :b_end, :days)"),
                            {
                                "dept_id": dept_id,
                                "name": name or 'Morning',
                                "start": start or '09:00',
                                "end": end or '17:00',
                                "grace": grace if grace is not None else 15,
                                "early_dep": early_dep if early_dep is not None else 10,
                                "b_start": b_start or '13:00',
                                "b_end": b_end or '14:00',
                                "days": 'Mon,Tue,Wed,Thu,Fri'
                            }
                        )
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading/migrating department_shifts: {e}")

    # 5. Upgrade cameras table columns
    if "cameras" in table_names:
        try:
            cam_columns = [col["name"] for col in inspector.get_columns("cameras")]
            with engine.begin() as conn:
                if "camera_type" not in cam_columns:
                    print("[Schema Upgrade] Adding cameras.camera_type column...")
                    conn.execute(text("ALTER TABLE cameras ADD COLUMN camera_type VARCHAR DEFAULT 'attendance'"))
                if "sub_location" not in cam_columns:
                    print("[Schema Upgrade] Adding cameras.sub_location column...")
                    conn.execute(text("ALTER TABLE cameras ADD COLUMN sub_location VARCHAR"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading cameras table: {e}")

    # 6. Upgrade videos table columns
    if "videos" in table_names:
        try:
            video_columns = [col["name"] for col in inspector.get_columns("videos")]
            with engine.begin() as conn:
                if "status" not in video_columns:
                    print("[Schema Upgrade] Adding videos.status column...")
                    conn.execute(text("ALTER TABLE videos ADD COLUMN status VARCHAR DEFAULT 'pending'"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading videos table: {e}")

    # 7. Upgrade review_queue table columns
    if "review_queue" in table_names:
        try:
            rq_columns = [col["name"] for col in inspector.get_columns("review_queue")]
            with engine.begin() as conn:
                if "suggested_staff_id" not in rq_columns:
                    print("[Schema Upgrade] Adding review_queue.suggested_staff_id column...")
                    conn.execute(text("ALTER TABLE review_queue ADD COLUMN suggested_staff_id VARCHAR"))
                if "confidence" not in rq_columns:
                    print("[Schema Upgrade] Adding review_queue.confidence column...")
                    conn.execute(text("ALTER TABLE review_queue ADD COLUMN confidence FLOAT"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading review_queue table: {e}")

    # 8. Ensure branch_activities table and columns exist
    if "branch_activities" not in table_names:
        try:
            BranchActivity.__table__.create(bind=engine, checkfirst=True)
            print("[Schema Upgrade] Created branch_activities table.")
        except Exception as e:
            print(f"[Schema Upgrade] Note on branch_activities: {e}")
    else:
        try:
            ba_columns = [col["name"] for col in inspector.get_columns("branch_activities")]
            with engine.begin() as conn:
                if "activity_code" in ba_columns:
                    conn.execute(text("ALTER TABLE branch_activities ALTER COLUMN activity_code DROP NOT NULL"))
                if "activity_id" not in ba_columns:
                    print("[Schema Upgrade] Adding branch_activities.activity_id column...")
                    conn.execute(text("ALTER TABLE branch_activities ADD COLUMN activity_id VARCHAR"))
                    if "activity_code" in ba_columns:
                        conn.execute(text("UPDATE branch_activities SET activity_id = activity_code WHERE activity_id IS NULL"))
                if "floor" not in ba_columns:
                    print("[Schema Upgrade] Adding branch_activities.floor column...")
                    conn.execute(text("ALTER TABLE branch_activities ADD COLUMN floor VARCHAR"))
                if "camera_direction" not in ba_columns:
                    print("[Schema Upgrade] Adding branch_activities.camera_direction column...")
                    conn.execute(text("ALTER TABLE branch_activities ADD COLUMN camera_direction VARCHAR"))
                if "camera_id" not in ba_columns:
                    print("[Schema Upgrade] Adding branch_activities.camera_id column...")
                    conn.execute(text("ALTER TABLE branch_activities ADD COLUMN camera_id VARCHAR"))
                if "camera_name" not in ba_columns:
                    print("[Schema Upgrade] Adding branch_activities.camera_name column...")
                    conn.execute(text("ALTER TABLE branch_activities ADD COLUMN camera_name VARCHAR"))
                if "camera_ids" not in ba_columns:
                    print("[Schema Upgrade] Adding branch_activities.camera_ids column...")
                    conn.execute(text("ALTER TABLE branch_activities ADD COLUMN camera_ids VARCHAR"))
                if "status" not in ba_columns:
                    print("[Schema Upgrade] Adding branch_activities.status column...")
                    conn.execute(text("ALTER TABLE branch_activities ADD COLUMN status VARCHAR DEFAULT 'active'"))
                    if "is_active" in ba_columns:
                        conn.execute(text("UPDATE branch_activities SET status = CASE WHEN is_active = true THEN 'active' ELSE 'inactive' END WHERE status IS NULL"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading branch_activities columns: {e}")

    # 8b. Ensure activities table and columns exist, and seed defaults
    if "activities" not in table_names:
        try:
            Activity.__table__.create(bind=engine, checkfirst=True)
            print("[Schema Upgrade] Created activities table.")
        except Exception as e:
            print(f"[Schema Upgrade] Note on activities: {e}")
    else:
        try:
            act_columns = [col["name"] for col in inspector.get_columns("activities")]
            with engine.begin() as conn:
                if "activity_id" not in act_columns:
                    print("[Schema Upgrade] Adding activities.activity_id column...")
                    conn.execute(text("ALTER TABLE activities ADD COLUMN activity_id VARCHAR"))
                    conn.execute(text("UPDATE activities SET activity_id = 'ACT-' || LPAD(id::text, 3, '0') WHERE activity_id IS NULL"))
                if "status" not in act_columns:
                    print("[Schema Upgrade] Adding activities.status column...")
                    conn.execute(text("ALTER TABLE activities ADD COLUMN status VARCHAR DEFAULT 'active'"))
                    if "is_active" in act_columns:
                        conn.execute(text("UPDATE activities SET status = CASE WHEN is_active = true THEN 'active' ELSE 'inactive' END WHERE status IS NULL"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading activities columns: {e}")
    
    try:
        with engine.begin() as conn:
            cnt = conn.execute(text("SELECT count(*) FROM activities")).scalar()
            if cnt == 0:
                print("[Schema Upgrade] Seeding initial global activities...")
                conn.execute(text("INSERT INTO activities (activity_id, name, description, status) VALUES ('ACT-001', 'Attendance', 'Staff entry, check-in and attendance recording', 'active')"))
                conn.execute(text("INSERT INTO activities (activity_id, name, description, status) VALUES ('ACT-002', 'Break', 'Meal and interval break tracking (In / Out)', 'active')"))
    except Exception as e:
        print(f"[Schema Upgrade] Seeding activities note: {e}")

    # 9. Upgrade cameras table columns
    if "cameras" in table_names:
        try:
            cam_columns = [col["name"] for col in inspector.get_columns("cameras")]
            with engine.begin() as conn:
                for legacy_col in ['nvr_ip', 'camera_ip', 'username', 'password', 'rtsp_main', 'rtsp_sub', 'site_id', 'ptz_channel', 'protocol', 'is_ptz', 'type']:
                    if legacy_col in cam_columns:
                        try:
                            conn.execute(text(f"ALTER TABLE cameras ALTER COLUMN {legacy_col} DROP NOT NULL"))
                        except Exception:
                            pass
                if "activity_id" not in cam_columns:
                    print("[Schema Upgrade] Adding cameras.activity_id column...")
                    conn.execute(text("ALTER TABLE cameras ADD COLUMN activity_id VARCHAR"))
                if "activity_name" not in cam_columns:
                    print("[Schema Upgrade] Adding cameras.activity_name column...")
                    conn.execute(text("ALTER TABLE cameras ADD COLUMN activity_name VARCHAR"))
                if "recording_path" not in cam_columns:
                    print("[Schema Upgrade] Adding cameras.recording_path column...")
                    conn.execute(text("ALTER TABLE cameras ADD COLUMN recording_path VARCHAR"))
                    if "rtsp_url" in cam_columns:
                        conn.execute(text("UPDATE cameras SET recording_path = rtsp_url WHERE recording_path IS NULL"))
                if "updated_at" not in cam_columns:
                    print("[Schema Upgrade] Adding cameras.updated_at column...")
                    conn.execute(text("ALTER TABLE cameras ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"))
        except Exception as e:
            print(f"[Schema Upgrade] Error upgrading cameras columns: {e}")


# Run the upgrade before creating new tables

upgrade_db_schema()

Base.metadata.create_all(bind=engine)





def get_db():

    db = SessionLocal()

    try:

        yield db

    finally:

        db.close()

