"""
EPIC System — Create Default Admin User
========================================
Run this ONCE to add the default admin account to the database.

Usage:
  cd backend
  python create_admin.py

Default credentials:
  Email:    admin@epic.com
  Password: admin123
  Role:     admin
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import bcrypt
from database.database import SessionLocal, User, Base, engine

# Ensure tables exist
Base.metadata.create_all(bind=engine)

def hash_password(plain: str) -> str:
    return bcrypt.hashpw(plain.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

def create_admin():
    db = SessionLocal()
    try:
        # Check if admin already exists
        existing = db.query(User).filter((User.email == "admin@epic.com") | (User.username == "admin")).first()
        if existing:
            existing.is_super_admin = True
            existing.is_first_login = False
            existing.hashed_password = hash_password("admin123")
            db.commit()
            print(f"\n  [INFO] Admin user existing updated:")
            print(f"         Email:    {existing.email}")
            print(f"         Username: {existing.username}")
            print(f"         Role:     {existing.role}")
            print(f"         SuperAdmin:{existing.is_super_admin}")
            return

        admin = User(
            username="admin",
            email="admin@epic.com",
            hashed_password=hash_password("admin123"),
            full_name="EPIC Administrator",
            role="admin",
            is_active=True,
            is_super_admin=True,
            is_first_login=False,
        )
        db.add(admin)
        db.commit()
        db.refresh(admin)

        print()
        print("=" * 50)
        print("  EPIC Admin User Created Successfully!")
        print("=" * 50)
        print(f"  ID:       {admin.id}")
        print(f"  Username: {admin.username}")
        print(f"  Email:    admin@epic.com")
        print(f"  Password: admin123")
        print(f"  Role:     {admin.role}")
        print()
        print("  [!] Change this password after first login!")
        print("=" * 50)
        print()

    finally:
        db.close()

if __name__ == "__main__":
    create_admin()
