"""
EPIC Department Assignment Seeder Fix
====================================
Assigns existing unassigned staff members to default departments (Engineering, Operations, Security, HR, Management)
so that the Departments page shows active staff counts and Staff table shows department badges!
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from database.database import SessionLocal, Staff, Department

def fix_staff_departments():
    db = SessionLocal()
    try:
        # Get or create default departments
        depts = db.query(Department).all()
        if not depts:
            default_dept_names = ["Engineering", "Operations", "Security", "HR", "Management"]
            for name in default_dept_names:
                d = Department(name=name, description=f"{name} Department")
                db.add(d)
            db.commit()
            depts = db.query(Department).all()

        dept_ids = [d.id for d in depts]
        if not dept_ids:
            print("❌ No departments found in database!")
            return

        unassigned_staff = db.query(Staff).filter((Staff.department_id == None) | (Staff.department_id == 0)).all()
        print(f"Found {len(unassigned_staff)} unassigned staff members.")

        for idx, staff in enumerate(unassigned_staff):
            assigned_dept_id = dept_ids[idx % len(dept_ids)]
            staff.department_id = assigned_dept_id

        db.commit()
        print(f"✅ Successfully assigned departments to {len(unassigned_staff)} staff members!")

        # Print Department Summary
        print("\n📊 Department Staff Breakdown:")
        for d in depts:
            cnt = db.query(Staff).filter(Staff.department_id == d.id).count()
            print(f"   • {d.name}: {cnt} staff assigned")

    except Exception as e:
        db.rollback()
        print(f"❌ Error assigning departments: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    fix_staff_departments()
