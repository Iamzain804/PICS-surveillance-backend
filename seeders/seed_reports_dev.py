"""
EPIC Reports Module - Comprehensive 90-Day Test Data Seeder
============================================================
PURPOSE: Development & Testing ONLY. Do NOT run in production.

Covers ALL Reporting module test scenarios:
  - All Branches / Specific Branch
  - All Departments / Specific Department
  - Attendance Activity (On Time, Late, Early Departure, Overtime, Short Hours, Absent, Missing Checkout)
  - Break Activity with First Floor and Ground Floor cameras
  - Today / This Week / Previous Week / This Month / Previous Month / Custom Range
  - Employee Name Search / Employee ID Search
  - Pagination (60 employees)
  - Sorting (all columns)
  - Excel Export with Shift column

IDEMPOTENT: Records are tagged with TST prefix. Safe to run multiple times.
            Each run first purges previous seeder data then re-inserts fresh data.

Run:
    cd d:\\zain\\web-admin-backend
    .venv\\Scripts\\activate
    python seeders/seed_reports_dev.py

Remove seeded data only (no re-seed):
    python seeders/seed_reports_dev.py --purge
"""

import sys
import io
import os
import random
import argparse
from datetime import datetime, timedelta

sys.path.insert(0, os.path.normpath(os.path.join(os.path.dirname(__file__), "..")))

from database.database import (
    SessionLocal, Branch, Camera, Staff, Video, Event, Department
)

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
DAYS_BACK     = 90    # 90-day history
NUM_EMPLOYEES = 60    # total employees across all branches
RNG_SEED      = 2024  # reproducible randomness
TAG           = "TST" # prefix that marks ALL records owned by this seeder

random.seed(RNG_SEED)

# ---------------------------------------------------------------------------
# Master data
# ---------------------------------------------------------------------------

BRANCHES = [
    {"name": "TST_Karachi HQ",            "address": "I.I. Chundrigar Road, Karachi", "manager_name": "Mr. Asim Raza"},
    {"name": "TST_Lahore Regional Office", "address": "Gulberg III, Lahore",           "manager_name": "Mr. Tariq Mehmood"},
    {"name": "TST_Islamabad Corporate",    "address": "Blue Area, Islamabad",           "manager_name": "Ms. Sana Mirza"},
    {"name": "TST_Rawalpindi Ops Hub",     "address": "Saddar, Rawalpindi",             "manager_name": "Mr. Fahad Iqbal"},
]

DEPARTMENTS = [
    "TST_IT",
    "TST_HR",
    "TST_Finance",
    "TST_Operations",
    "TST_Sales",
]

# 6 cameras per branch:
#   2 attendance (checkin / checkout)
#   2 First Floor break (breakin / breakout)
#   2 Ground Floor break (breakin / breakout)
# sub_location is the value the frontend Break-Area filter passes as camera_id
CAMERAS_TEMPLATE = [
    {
        "suffix": "ATT_IN",
        "name_tmpl": "{b}_Entrance",
        "loc": "Main Entrance",
        "sub_location": "Main Entrance",
        "type": "attendance",
        "is_checkin": True,
        "is_checkout": False,
    },
    {
        "suffix": "ATT_OUT",
        "name_tmpl": "{b}_Exit",
        "loc": "Main Exit",
        "sub_location": "Main Exit",
        "type": "attendance",
        "is_checkin": False,
        "is_checkout": True,
    },
    # First Floor Break cameras
    {
        "suffix": "FF_BI",
        "name_tmpl": "{b}_FirstFloor_BreakIn",
        "loc": "First Floor Cafeteria",
        "sub_location": "First Floor Break",
        "type": "break",
        "is_checkin": True,
        "is_checkout": False,
    },
    {
        "suffix": "FF_BO",
        "name_tmpl": "{b}_FirstFloor_BreakOut",
        "loc": "First Floor Cafeteria",
        "sub_location": "First Floor Break",
        "type": "break",
        "is_checkin": False,
        "is_checkout": True,
    },
    # Ground Floor Break cameras
    {
        "suffix": "GF_BI",
        "name_tmpl": "{b}_GroundFloor_BreakIn",
        "loc": "Ground Floor Cafeteria",
        "sub_location": "Ground Floor Break",
        "type": "break",
        "is_checkin": True,
        "is_checkout": False,
    },
    {
        "suffix": "GF_BO",
        "name_tmpl": "{b}_GroundFloor_BreakOut",
        "loc": "Ground Floor Cafeteria",
        "sub_location": "Ground Floor Break",
        "type": "break",
        "is_checkin": False,
        "is_checkout": True,
    },
]

# (label, shift_start_ampm, shift_end_ampm, grace_mins)
SHIFTS = [
    ("Morning Shift", "09:00 AM", "06:00 PM", 15),
    ("Early Shift",   "08:00 AM", "05:00 PM", 10),
    ("Late Shift",    "10:00 AM", "07:00 PM", 20),
    ("Flex Shift",    "09:30 AM", "06:30 PM", 30),
]


# ---------------------------------------------------------------------------
# Employee factory
# ---------------------------------------------------------------------------

def _build_employees():
    first_names = [
        "Ali", "Bilal", "Zain", "Farhan", "Usman", "Hassan", "Kamran", "Saad",
        "Imran", "Asif", "Raza", "Adnan", "Talha", "Waqar", "Shahid",
        "Mubashir", "Naeem", "Ghulam", "Abdul", "Zaheer", "Ayesha", "Sana",
        "Nadia", "Farah", "Hira", "Maryam", "Zara", "Sara", "Amna", "Rubab",
        "Omar", "Tariq", "Danish", "Irfan", "Shoaib", "Rana", "Waqas", "Sajjad",
        "Qasim", "Faizan", "Abubakar", "Muzammil", "Iqbal", "Ahmad", "Qaiser",
        "Rasool", "Amjad", "Nauman", "Pervez", "Zubair", "Junaid", "Kashif",
        "Faisal", "Arif", "Aamir", "Mukhtar", "Noman", "Haroon", "Babar", "Salman",
    ]
    last_names = [
        "Khan", "Ahmed", "Ali", "Butt", "Malik", "Shah", "Qureshi", "Mirza",
        "Akhtar", "Hussain", "Siddiqui", "Raza", "Awan", "Gondal", "Chaudhry",
        "Lodhi", "Soomro", "Mengal", "Baloch", "Jilani", "Rizvi", "Siddiqi",
        "Sheikh", "Baig", "Zaidi", "Naqvi", "Memon", "Ansari", "Bhatti",
        "Tariq", "Irfan", "Mehmood", "Saleem", "Warriach", "Nadeem", "Gilani",
        "Khattak", "Alvi", "Zeeshan", "Mahmood", "Haider", "Rajput",
    ]
    rows = []
    for i in range(NUM_EMPLOYEES):
        fn  = first_names[i % len(first_names)]
        ln  = last_names[(i + 3) % len(last_names)]
        sid = "TST{:03d}".format(i + 1)
        email = "{}.{}{}@tst.epic.com".format(fn.lower(), ln.lower(), i)
        rows.append((sid, "{} {}".format(fn, ln), email, i % len(DEPARTMENTS), i % len(SHIFTS)))
    return rows


EMPLOYEES = _build_employees()


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

def _ampm_to_mins(s):
    parts = s.split()
    h, m = map(int, parts[0].split(":"))
    ap = parts[1].upper()
    if ap == "PM" and h != 12:
        h += 12
    if ap == "AM" and h == 12:
        h = 0
    return h * 60 + m


def _attendance_scenario(eidx, day_offset):
    """Deterministic spread: on_time 30%, within_grace 15%, late 15%,
    early_departure 10%, overtime 10%, short_hours 10%, absent 5%, missing_checkout 5%"""
    b = (eidx * 13 + day_offset * 7) % 100
    if b < 30: return "on_time"
    if b < 45: return "within_grace"
    if b < 60: return "late"
    if b < 70: return "early_departure"
    if b < 80: return "overtime"
    if b < 90: return "short_hours"
    if b < 95: return "absent"
    return "missing_checkout"


def _num_breaks(eidx, day_offset):
    """0-5 breaks per employee per day."""
    b = (eidx * 11 + day_offset * 5) % 20
    if b < 4:  return 0
    if b < 10: return 1
    if b < 14: return 2
    if b < 17: return 3
    if b < 19: return 4
    return 5


def _break_floor(eidx, day_offset, bk_num):
    """Alternate breaks between First Floor and Ground Floor."""
    return "first" if (eidx + day_offset + bk_num) % 2 == 0 else "ground"


# ---------------------------------------------------------------------------
# Purge
# ---------------------------------------------------------------------------

def purge(db):
    print("\n[PURGE] Removing previous seeder records (TST prefix)...")

    tst_staff_ids = [s.staff_id for s in db.query(Staff).filter(Staff.staff_id.like("TST%")).all()]
    if tst_staff_ids:
        n = db.query(Event).filter(Event.employee_id.in_(tst_staff_ids)).delete(synchronize_session=False)
        print("  - {} events deleted".format(n))

    tst_cam_names = [c.name for c in db.query(Camera).filter(Camera.camera_id.like("CAM_TST%")).all()]
    if tst_cam_names:
        vids = db.query(Video).filter(Video.camera_name.in_(tst_cam_names)).all()
        for v in vids:
            db.delete(v)
        print("  - {} videos deleted".format(len(vids)))

    n = db.query(Staff).filter(Staff.staff_id.like("TST%")).delete(synchronize_session=False)
    print("  - {} staff deleted".format(n))

    n = db.query(Camera).filter(Camera.camera_id.like("CAM_TST%")).delete(synchronize_session=False)
    print("  - {} cameras deleted".format(n))

    n = db.query(Branch).filter(Branch.name.like("TST_%")).delete(synchronize_session=False)
    print("  - {} branches deleted".format(n))

    n = db.query(Department).filter(Department.name.like("TST_%")).delete(synchronize_session=False)
    print("  - {} departments deleted".format(n))

    db.commit()
    print("[PURGE] Done.\n")


# ---------------------------------------------------------------------------
# Main seeder
# ---------------------------------------------------------------------------

def seed():
    db = SessionLocal()
    try:
        print("=" * 68)
        print("  EPIC Reports Module - 90-Day Dev Test Data Seeder")
        print("=" * 68)

        # Step 0: purge previous run (idempotency)
        purge(db)

        # ---- Step 1: Branches ----------------------------------------
        print("\n[1/6] Creating branches...")
        branch_objs = []
        for bd in BRANCHES:
            b = Branch(
                name=bd["name"],
                address=bd["address"],
                manager_name=bd["manager_name"],
                status="active",
            )
            db.add(b)
            branch_objs.append(b)
        db.commit()
        for b in branch_objs:
            db.refresh(b)
        print("      OK  {} branches".format(len(branch_objs)))

        # ---- Step 2: Departments ----------------------------------------
        print("\n[2/6] Creating departments...")
        dept_map = {}
        for dname in DEPARTMENTS:
            d = Department(name=dname, description="Dev test: {}".format(dname))
            db.add(d)
            db.flush()
            dept_map[dname] = d
        db.commit()
        print("      OK  {} departments".format(len(dept_map)))

        # ---- Step 3: Cameras (6 per branch) -------------------------------
        print("\n[3/6] Creating cameras (6 per branch)...")
        BRANCH_SHORT = ["KHI", "LHR", "ISB", "RWP"]
        # cam_idx[branch_id][suffix] = Camera obj
        cam_idx = {}
        for bidx, b in enumerate(branch_objs):
            p = "TST_{}".format(BRANCH_SHORT[bidx])
            cam_idx[b.id] = {}
            for ct in CAMERAS_TEMPLATE:
                cam_id   = "CAM_{}_{}".format(p, ct["suffix"])
                cam_name = ct["name_tmpl"].format(b=p)
                c = Camera(
                    camera_id    = cam_id,
                    name         = cam_name,
                    branch_id    = b.id,
                    location     = ct["loc"],
                    sub_location = ct["sub_location"],
                    camera_type  = ct["type"],
                    is_checkin   = ct["is_checkin"],
                    is_checkout  = ct["is_checkout"],
                    status       = "online",
                )
                db.add(c)
                cam_idx[b.id][ct["suffix"]] = c
        db.commit()
        print("      OK  {} cameras total ({} per branch)".format(
            len(branch_objs) * len(CAMERAS_TEMPLATE), len(CAMERAS_TEMPLATE)))

        # ---- Step 4: Staff -----------------------------------------------
        print("\n[4/6] Creating {} employees...".format(NUM_EMPLOYEES))
        staff_objs = []
        for eidx, (sid, name, email, dept_idx, shift_idx) in enumerate(EMPLOYEES):
            branch   = branch_objs[eidx % len(branch_objs)]
            shift    = SHIFTS[shift_idx]
            dept_obj = dept_map.get(DEPARTMENTS[dept_idx])
            s = Staff(
                staff_id          = sid,
                name              = name,
                email             = email,
                branch_id         = branch.id,
                department_id     = dept_obj.id if dept_obj else None,
                shift_start_time  = shift[1],
                shift_end_time    = shift[2],
                has_face_encoding = True,
            )
            db.add(s)
            staff_objs.append(s)
        db.commit()
        for s in staff_objs:
            db.refresh(s)
        print("      OK  {} employees across {} branches x {} departments".format(
            len(staff_objs), len(branch_objs), len(DEPARTMENTS)))

        # ---- Step 5: Events (90 days) ------------------------------------
        print("\n[5/6] Generating {}-day attendance + break events...".format(DAYS_BACK))
        today        = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        total_events = 0
        vcache       = {}   # (cam_id, date_str) -> Video

        def _vid(cam_id, cam_name, date_str):
            key = (cam_id, date_str)
            if key in vcache:
                return vcache[key]
            fname = "{}_{}.mp4".format(cam_name, date_str)
            v = Video(
                filename         = fname,
                folder_type      = "mixed",
                file_path        = "/dev_recordings/{}".format(fname),
                file_size_mb     = round(random.uniform(100, 600), 1),
                duration_seconds = round(random.uniform(3600, 28800)),
                resolution       = "1920x1080",
                fps              = 25.0,
                video_start_time = "{} 07:00:00".format(date_str),
                camera_name      = cam_name,
                status           = "completed",
            )
            db.add(v)
            db.flush()
            vcache[key] = v
            return v

        for day_offset in range(DAYS_BACK):
            edate   = today - timedelta(days=day_offset)
            dstr    = edate.strftime("%Y-%m-%d")
            weekday = edate.weekday()  # 0=Mon ... 6=Sun

            for eidx, s in enumerate(staff_objs):
                # Weekend: Sunday always off; Saturday 20% attendance
                if weekday == 6:
                    continue
                if weekday == 5 and random.random() > 0.20:
                    continue

                sc = _attendance_scenario(eidx, day_offset)
                if sc == "absent":
                    continue

                shift    = SHIFTS[eidx % len(SHIFTS)]
                ss_mins  = _ampm_to_mins(shift[1])
                se_mins  = _ampm_to_mins(shift[2])
                grace    = shift[3]
                cams     = cam_idx[s.branch_id]

                # --- Check-in time ---
                if sc == "on_time":
                    ci = ss_mins + random.randint(-5, 0)
                elif sc == "within_grace":
                    ci = ss_mins + random.randint(1, grace)
                elif sc == "late":
                    ci = ss_mins + grace + random.randint(5, 50)
                elif sc in ("early_departure", "overtime", "missing_checkout"):
                    ci = ss_mins + random.randint(-10, 5)
                elif sc == "short_hours":
                    ci = ss_mins + random.randint(30, 90)
                else:
                    ci = ss_mins

                # --- Check-out time ---
                if sc == "early_departure":
                    co = se_mins - random.randint(30, 120)
                elif sc == "overtime":
                    co = se_mins + random.randint(30, 180)
                elif sc == "short_hours":
                    co = ci + random.randint(150, 360)
                elif sc == "missing_checkout":
                    co = None
                else:
                    co = se_mins + random.randint(-10, 15)

                if co is not None and co < ci + 30:
                    co = ci + 30

                # --- Check-in event ---
                att_in = cams["ATT_IN"]
                v_ci   = _vid(att_in.camera_id, att_in.name, dstr)
                ci_dt  = edate.replace(hour=ci // 60 % 24, minute=ci % 60, second=random.randint(0, 59))
                db.add(Event(
                    video_id               = v_ci.id,
                    camera_role            = "checkin",
                    track_id               = eidx * 10000 + day_offset,
                    event_type             = "check_in",
                    timestamp              = ci_dt.strftime("%d-%m-%Y %H:%M:%S"),
                    frame_number           = max(0, (ci - 420) * 25 * 60),
                    confidence             = round(random.uniform(0.90, 0.99), 3),
                    status                 = "completed",
                    employee_id            = s.staff_id,
                    employee_name          = s.name,
                    recognition_confidence = round(random.uniform(0.92, 0.99), 3),
                    recognition_status     = "recognized",
                    recognized_at          = ci_dt,
                ))
                total_events += 1

                if co is not None:
                    # --- Check-out event ---
                    att_out = cams["ATT_OUT"]
                    v_co    = _vid(att_out.camera_id, att_out.name, dstr)
                    co_dt   = edate.replace(hour=co // 60 % 24, minute=co % 60, second=random.randint(0, 59))
                    db.add(Event(
                        video_id               = v_co.id,
                        camera_role            = "checkout",
                        track_id               = eidx * 10000 + day_offset + 5000,
                        event_type             = "check_out",
                        timestamp              = co_dt.strftime("%d-%m-%Y %H:%M:%S"),
                        frame_number           = max(0, (co - 420) * 25 * 60),
                        confidence             = round(random.uniform(0.88, 0.99), 3),
                        status                 = "completed",
                        employee_id            = s.staff_id,
                        employee_name          = s.name,
                        recognition_confidence = round(random.uniform(0.90, 0.99), 3),
                        recognition_status     = "recognized",
                        recognized_at          = co_dt,
                    ))
                    total_events += 1

                    # --- Break events ---
                    nb      = _num_breaks(eidx, day_offset)
                    w_start = ci + 60     # first break no earlier than 1 hr after check-in
                    w_end   = co - 30     # last break ends >=30 min before check-out

                    if nb > 0 and (w_end - w_start) < 30:
                        nb = 0

                    prev_bo = w_start
                    for bk in range(nb):
                        floor  = _break_floor(eidx, day_offset, bk)
                        bi_key = "FF_BI" if floor == "first" else "GF_BI"
                        bo_key = "FF_BO" if floor == "first" else "GF_BO"

                        remaining = w_end - prev_bo
                        if remaining < 15:
                            break
                        slot_gap = max(15, remaining // max(1, nb - bk))
                        bi_mins  = prev_bo + random.randint(10, max(11, slot_gap // 2))
                        if bi_mins >= w_end - 5:
                            break

                        dur     = random.randint(5, 45)
                        bo_mins = bi_mins + dur
                        if bo_mins >= w_end:
                            bo_mins  = w_end - 3
                            dur      = bo_mins - bi_mins
                        if dur < 3:
                            break

                        prev_bo = bo_mins

                        bi_cam = cams[bi_key]
                        bo_cam = cams[bo_key]
                        v_bi   = _vid(bi_cam.camera_id, bi_cam.name, dstr)
                        v_bo   = _vid(bo_cam.camera_id, bo_cam.name, dstr)

                        bi_dt = edate.replace(
                            hour=bi_mins // 60 % 24, minute=bi_mins % 60,
                            second=random.randint(0, 30))
                        bo_dt = edate.replace(
                            hour=bo_mins // 60 % 24, minute=bo_mins % 60,
                            second=random.randint(0, 30))

                        db.add(Event(
                            video_id               = v_bi.id,
                            camera_role            = "breakin",
                            track_id               = eidx * 10000 + day_offset + bk * 1000 + 2000,
                            event_type             = "break_start",
                            timestamp              = bi_dt.strftime("%d-%m-%Y %H:%M:%S"),
                            frame_number           = max(0, (bi_mins - 420) * 25 * 60),
                            confidence             = round(random.uniform(0.88, 0.99), 3),
                            status                 = "completed",
                            employee_id            = s.staff_id,
                            employee_name          = s.name,
                            recognition_confidence = round(random.uniform(0.88, 0.99), 3),
                            recognition_status     = "recognized",
                            recognized_at          = bi_dt,
                        ))
                        db.add(Event(
                            video_id               = v_bo.id,
                            camera_role            = "breakout",
                            track_id               = eidx * 10000 + day_offset + bk * 1000 + 3000,
                            event_type             = "break_end",
                            timestamp              = bo_dt.strftime("%d-%m-%Y %H:%M:%S"),
                            frame_number           = max(0, (bo_mins - 420) * 25 * 60),
                            confidence             = round(random.uniform(0.88, 0.99), 3),
                            status                 = "completed",
                            employee_id            = s.staff_id,
                            employee_name          = s.name,
                            recognition_confidence = round(random.uniform(0.88, 0.99), 3),
                            recognition_status     = "recognized",
                            recognized_at          = bo_dt,
                        ))
                        total_events += 2

            # Commit per-day to keep memory usage bounded
            db.commit()

            if (day_offset + 1) % 15 == 0:
                print("      ... day {}/{}  |  events so far: {:,}".format(
                    day_offset + 1, DAYS_BACK, total_events))

        print("      OK  {:,} video records".format(len(vcache)))
        print("      OK  {:,} events".format(total_events))

        # ---- Step 6: Summary -------------------------------------------
        print("\n[6/6] Final database counts (TST records only):")
        print("      Branches    : {}".format(
            db.query(Branch).filter(Branch.name.like("TST_%")).count()))
        print("      Departments : {}".format(
            db.query(Department).filter(Department.name.like("TST_%")).count()))
        print("      Cameras     : {}".format(
            db.query(Camera).filter(Camera.camera_id.like("CAM_TST%")).count()))
        print("      Staff       : {}".format(
            db.query(Staff).filter(Staff.staff_id.like("TST%")).count()))
        print("      Videos      : {:,}".format(len(vcache)))
        print("      Events      : {:,}".format(total_events))

        print("\n" + "=" * 68)
        print("  Seeding complete!  All 90-day report scenarios are testable.")
        print("  Remove data:  python seeders/seed_reports_dev.py --purge")
        print("=" * 68 + "\n")

    except Exception as exc:
        import traceback
        print("\n[ERROR] {}".format(exc))
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="EPIC Reports Module 90-day dev/test seeder."
    )
    parser.add_argument(
        "--purge",
        action="store_true",
        help="Remove all seeder records (TST prefix) and exit without re-seeding.",
    )
    args = parser.parse_args()

    if args.purge:
        _db = SessionLocal()
        try:
            purge(_db)
        finally:
            _db.close()
    else:
        seed()
