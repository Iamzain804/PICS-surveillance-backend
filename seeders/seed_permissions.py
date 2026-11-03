import sys
import os

# Add parent directory to path so we can import from database/ folder
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from database.database import SessionLocal, Base, engine, Permission, Role, Department, User, Shift

def seed_data():
    # Ensure tables exist
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        print("\n=== STEP 1: Seeding Departments ===")
        departments_data = [
            {"name": "Operations", "description": "Operations and logistics management"},
            {"name": "HR", "description": "Human resources and personnel"},
            {"name": "Engineering", "description": "AI systems and software engineering"},
            {"name": "Security", "description": "Physical security and CCTV monitoring"}
        ]
        
        seeded_departments = {}
        for dept in departments_data:
            existing = db.query(Department).filter(Department.name == dept["name"]).first()
            if not existing:
                new_dept = Department(name=dept["name"], description=dept["description"])
                db.add(new_dept)
                db.commit()
                db.refresh(new_dept)
                
                # Seed default shift
                default_shift = Shift(
                    department_id=new_dept.id,
                    shift_name="Morning",
                    shift_start="09:00",
                    shift_end="17:00",
                    grace_time_mins=15,
                    break_start="13:00",
                    break_end="14:00"
                )
                db.add(default_shift)
                db.commit()
                
                seeded_departments[dept["name"]] = new_dept
                print(f"  [+] Created Department: {dept['name']} with default Morning shift")
            else:
                seeded_departments[dept["name"]] = existing
                # Check if shifts are missing and backfill
                if len(existing.shifts) == 0:
                    default_shift = Shift(
                        department_id=existing.id,
                        shift_name="Morning",
                        shift_start="09:00",
                        shift_end="17:00",
                        grace_time_mins=15,
                        break_start="13:00",
                        break_end="14:00"
                    )
                    db.add(default_shift)
                    db.commit()
                    print(f"  [+] Added default Morning shift to existing Department: {dept['name']}")
                else:
                    print(f"  [.] Department already exists: {dept['name']}")

        print("\n=== STEP 2: Seeding Permissions ===")
        permissions_data = [
            # Staff Management
            {"name": "add_staff", "description": "Add new employee records", "group": "Staff Management"},
            {"name": "view_staff", "description": "View employee profiles and records", "group": "Staff Management"},
            {"name": "update_staff", "description": "Edit employee profile details", "group": "Staff Management"},
            {"name": "remove_staff", "description": "Remove or deactivate employee records", "group": "Staff Management"},
            {"name": "status_staff", "description": "Activate or deactivate employee records", "group": "Staff Management"},
            {"name": "change_staff_password", "description": "Change staff access password", "group": "Staff Management"},
          # {"name": "override_staff_shift", "description": "Override staff duty hours info", "group": "Staff Management"},
            
            # Branch Management
            {"name": "add_branch", "description": "Add new branch/office locations", "group": "Branch Management"},
            {"name": "view_branch", "description": "View branch details and performance metrics", "group": "Branch Management"},
            {"name": "update_branch", "description": "Modify branch details", "group": "Branch Management"},
            {"name": "remove_branch", "description": "Deactivate or delete branch locations", "group": "Branch Management"},
            {"name": "status_branch", "description": "Activate or deactivate branch locations", "group": "Branch Management"},
            
            # Department Management
            {"name": "add_department", "description": "Add new departments", "group": "Department Management"},
            {"name": "view_department", "description": "View department configurations", "group": "Department Management"},
            {"name": "update_department", "description": "Edit department descriptions or names", "group": "Department Management"},
            {"name": "remove_department", "description": "Remove departments", "group": "Department Management"},
            {"name": "status_department", "description": "Activate or deactivate departments", "group": "Department Management"},
            
            # User Management (Dashboard Users)
            {"name": "add_user", "description": "Add new backend dashboard users", "group": "User Management"},
            {"name": "view_user", "description": "View list of registered system users", "group": "User Management"},
            {"name": "update_user", "description": "Edit roles and statuses of system users", "group": "User Management"},
            {"name": "remove_user", "description": "Deactivate dashboard users", "group": "User Management"},
            {"name": "status_user", "description": "Activate or deactivate system users", "group": "User Management"},
            
            
            # Reports
            {"name": "view_reports", "description": "Analyze attendance summaries and timelines", "group": "Reports"},
            {"name": "export_reports", "description": "Download processed Excel reports", "group": "Reports"},
            {"name": "view_events", "description": "Access dashboard recognition events logs", "group": "Reports"},
            {"name": "view_logs", "description": "View system execution stdout/stderr logs", "group": "Reports"},
            {"name": "control_pipeline", "description": "Start, stop, or configure the offline video AI pipeline", "group": "Reports"},
            {"name": "manage_roles", "description": "Create, modify, or delete roles and permission mappings", "group": "Roles & Permissions Admin"},
        ]

        active_permissions = []
        for perm in permissions_data:
            existing = db.query(Permission).filter(Permission.name == perm["name"]).first()
            if not existing:
                new_perm = Permission(name=perm["name"], description=perm["description"], group=perm["group"])
                db.add(new_perm)
                db.commit()
                db.refresh(new_perm)
                active_permissions.append(new_perm)
                print(f"  [+] Created Permission: {perm['name']} ({perm['group']})")
            else:
                # Update description and group just in case
                existing.description = perm["description"]
                existing.group = perm["group"]
                db.commit()
                active_permissions.append(existing)
                print(f"  [.] Permission synced: {perm['name']}")

        # Clean up stale permissions
        db_permission_names = [p.name for p in db.query(Permission).all()]
        active_names = [p["name"] for p in permissions_data]
        stale_names = [name for name in db_permission_names if name not in active_names]
        if stale_names:
            print("\n=== CLEANUP: Removing stale permissions ===")
            for name in stale_names:
                sp = db.query(Permission).filter(Permission.name == name).first()
                if sp:
                    print(f"  [-] Deleting stale permission: {name}")
                    db.delete(sp)
            db.commit()

        print("\n=== STEP 3: Seeding Default Roles ===")
        # Seed Admin Role
        admin_role = db.query(Role).filter(Role.name == "Admin").first()
        if not admin_role:
            admin_role = Role(name="Admin", is_active=True)
            db.add(admin_role)
            db.commit()
            db.refresh(admin_role)
            print("  [+] Created Admin Role")
        
        # Admin gets all permissions
        admin_role.permissions = active_permissions
        db.commit()
        print("  [.] Mapped all permissions to Admin Role")

        # Seed Viewer Role
        viewer_role = db.query(Role).filter(Role.name == "Viewer").first()
        if not viewer_role:
            viewer_role = Role(name="Viewer", is_active=True)
            db.add(viewer_role)
            db.commit()
            db.refresh(viewer_role)
            print("  [+] Created Viewer Role")
        
        # Viewer gets read-only permissions
        viewer_perms = [
            p for p in active_permissions 
            if p.name in ["read_staff", "read_branch", "read_department", "read_user", "view_events", "view_logs", "view_reports"]
        ]
        viewer_role.permissions = viewer_perms
        db.commit()
        print(f"  [.] Mapped {len(viewer_perms)} read-only permissions to Viewer Role")

        print("\n=== STEP 4: Configure Admin User ===")
        admin_user = db.query(User).filter(User.email == "admin@epic.com").first()
        if admin_user:
            admin_user.is_super_admin = True
            admin_user.role_id = admin_role.id
            admin_user.role = "admin" # backwards compatibility
            admin_user.department_id = seeded_departments["Engineering"].id if "Engineering" in seeded_departments else None
            db.commit()
            print("  [OK] Updated 'admin@epic.com' as Super Admin with Admin Role and Engineering Department.")
        else:
            print("  [!] Default admin@epic.com user not found. Run python create_admin.py first.")

        print("\n[SUCCESS] Seeding complete!")

    except Exception as e:
        db.rollback()
        print(f"\n[FATAL ERROR] Seeding failed: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
