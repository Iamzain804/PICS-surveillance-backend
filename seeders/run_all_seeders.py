"""
EPIC Enterprise Unified Master Seeder Runner
==============================================
Runs all seeders in exact logical order:
1. Base DB Schema & Admin User Seeder (seed_database.py)
2. Roles & Permissions Matrix Seeder (seed_permissions.py)
3. Admin Account Seeder (create_admin.py)
4. Realistic Attendance & Break Demo Data Generator (generate_test_data.py)
5. [DEV ONLY] 90-Day Reports Module Test Data (seed_reports_dev.py)
   Run with --dev flag:  python run_all_seeders.py --dev
   Remove dev data only: python seeders/seed_reports_dev.py --purge
"""

import sys
import os
import argparse

# Add backend directory to sys.path
sys.path.insert(0, os.path.normpath(os.path.join(os.path.dirname(__file__), "..")))

def run_all(include_dev=False):
    print("Starting EPIC Master Database Seeding Process...\n")
    
    # 1. Base Database & Core Metadata
    try:
        from seeders.seed_database import seed_database
        print("--- [1/4] Running Base Database Seeder ---")
        seed_database()
    except Exception as e:
        print(f"Base seeder warning/error: {e}")

    # 2. Roles & Permissions Matrix
    try:
        from seeders.seed_permissions import seed_data
        print("\n--- [2/4] Running Roles & Permissions Seeder ---")
        seed_data()
    except Exception as e:
        print(f"Permissions seeder warning/error: {e}")

    # 3. Admin Account Creation
    try:
        from seeders.create_admin import create_admin
        print("\n--- [3/4] Running Admin Account Seeder ---")
        create_admin()
    except Exception as e:
        print(f"Admin seeder warning/error: {e}")

    # 4. Realistic Demo Events Generation
    try:
        from seeders.generate_test_data import seed_test_data
        print("\n--- [4/4] Generating Realistic Demo Attendance & Break Data ---")
        seed_test_data()
    except Exception as e:
        print(f"Test data seeder warning/error: {e}")

    # 5. [DEV ONLY] 90-Day Reports Module Test Data
    if include_dev:
        try:
            from seeders.seed_reports_dev import seed as seed_reports_dev
            print("\n--- [5/5] [DEV] Generating 90-Day Reports Module Test Data ---")
            print("          (TST_ prefix records — safe to remove with --purge)")
            seed_reports_dev()
        except Exception as e:
            print(f"Dev reports seeder warning/error: {e}")

    print("\nAll Database Seeders completed successfully!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="EPIC Master Database Seeder Runner")
    parser.add_argument(
        "--dev",
        action="store_true",
        help="Also run the 90-day Reports Module dev/test seeder (seed_reports_dev.py).",
    )
    args = parser.parse_args()
    run_all(include_dev=args.dev)

