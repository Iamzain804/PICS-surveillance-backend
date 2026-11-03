"""
EPIC Enterprise Database Seeder
================================
Populates initial database records for:
- Initial Admin & User Accounts
- Branches
- Departments
- Camera Devices & Roles
- Staff / Employees
- Attendance & Break Events
"""

import sys
import os
from datetime import datetime, timedelta

# Add backend directory to path
sys.path.insert(0, os.path.normpath(os.path.join(os.path.dirname(__file__), "..")))

from database.database import SessionLocal, init_db, User, Staff, Branch, Department, Camera, Event, Video

def seed_database():
    print("🌱 Initializing Database schema and seeding initial data...")
    init_db()
    db = SessionLocal()

    try:
        # 1. Seed Admin User
        admin_user = db.query(User).filter(User.email == "admin@epic.com").first()
        if not admin_user:
            from passlib.context import CryptContext
            pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
            admin_user = User(
                username="admin",
                email="admin@epic.com",
                hashed_password=pwd_context.hash("admin123"),
                full_name="System Administrator",
                role="admin",
                is_active=True
            )
            db.add(admin_user)
            db.commit()
            print("  ✅ Admin user created (admin@epic.com / admin123)")

        # 2. Seed Branches
        branches_data = ["MMA Main Branch", "Mall Road Branch", "Gulberg Branch"]
        branch_objs = {}
        for bname in branches_data:
            b = db.query(Branch).filter(Branch.name == bname).first()
            if not b:
                b = Branch(name=bname, location=bname.replace(" Branch", ""))
                db.add(b)
                db.commit()
                db.refresh(b)
            branch_objs[bname] = b
        print("  ✅ Branches seeded.")

        # 3. Seed Departments
        departments_data = ["Management", "Sales & Retail", "IT & Support", "HR", "Finance"]
        dept_objs = {}
        for dname in departments_data:
            d = db.query(Department).filter(Department.name == dname).first()
            if not d:
                d = Department(name=dname)
                db.add(d)
                db.commit()
                db.refresh(d)
            dept_objs[dname] = d
        print("  ✅ Departments seeded.")

        # 4. Cameras seeding skipped (clean db)
        print("  ℹ️ Cameras seeding skipped.")

        # 5. Seed Staff Members
        staff_data = [
            {"staff_id": "EMP-001", "name": "Muhammad Ali", "department_name": "Management", "shift_start": "09:00 AM", "shift_end": "06:00 PM"},
            {"staff_id": "EMP-002", "name": "Usman Hassan", "department_name": "Sales & Retail", "shift_start": "09:00 AM", "shift_end": "06:00 PM"},
            {"staff_id": "EMP-003", "name": "Fatima Zahra", "department_name": "IT & Support", "shift_start": "09:00 AM", "shift_end": "06:00 PM"},
            {"staff_id": "EMP-004", "name": "Ayesha Malik", "department_name": "HR", "shift_start": "09:00 AM", "shift_end": "06:00 PM"},
            {"staff_id": "EMP-005", "name": "Zaid Ahmed", "department_name": "Finance", "shift_start": "09:00 AM", "shift_end": "06:00 PM"},
        ]
        
        main_branch = list(branch_objs.values())[0]
        for sinfo in staff_data:
            dept = dept_objs.get(sinfo["department_name"])
            st = db.query(Staff).filter(Staff.staff_id == sinfo["staff_id"]).first()
            if not st:
                st = Staff(
                    staff_id=sinfo["staff_id"],
                    name=sinfo["name"],
                    branch_id=main_branch.id,
                    department_id=dept.id if dept else None,
                    shift_start_time=sinfo["shift_start"],
                    shift_end_time=sinfo["shift_end"],
                    status="active"
                )
                db.add(st)
        db.commit()
        print("  ✅ Staff members seeded.")

        print("🎉 Database successfully seeded!")

    except Exception as e:
        db.rollback()
        print(f"❌ Database seeding error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
