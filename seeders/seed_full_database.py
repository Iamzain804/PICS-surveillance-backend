#!/usr/bin/env python3
"""
EPIC System - Complete Database Seeder & Data Exporter
=====================================================
Seeds the entire PostgreSQL database with all tables, master records, staff,
departments, branches, shifts, cameras, videos, and events data.

Usage:
  # 1. Seed database from json data file (safe insert / upsert):
  python seed_full_database.py

  # 2. Wipe existing data and perform clean seed:
  python seed_full_database.py --clean

  # 3. Export latest DB state into seed data file:
  python seed_full_database.py --export

Data file: epic_seed_data.json
SQL dump: epic_database_full_dump.sql
"""

import os
import sys
import json
import argparse
from datetime import datetime, date, time
import psycopg2
from psycopg2.extras import RealDictCursor

# Add parent directory
BACKEND_DIR = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)

from database.database import Base, engine

SEED_DATA_JSON = os.path.join(os.path.dirname(__file__), "epic_seed_data.json")

# Insertion order strictly respecting foreign keys
TABLES_ORDER = [
    "roles",
    "permissions",
    "role_permissions",
    "departments",
    "branches",
    "cameras",
    "staff",
    "users",
    "department_shifts",
    "videos",
    "branch_activities",
    "activities",
    "events",
]


def get_db_connection():
    """Connect to PostgreSQL using env config or defaults."""
    db_url = os.environ.get("DATABASE_URL")
    if db_url and db_url.startswith("postgresql://"):
        return psycopg2.connect(db_url)
    host = os.environ.get("POSTGRES_HOST", "localhost")
    port = os.environ.get("POSTGRES_PORT", "5432")
    user = os.environ.get("POSTGRES_USER", "postgres")
    pwd = os.environ.get("POSTGRES_PASSWORD", "1234")
    dbname = os.environ.get("POSTGRES_DB", "testdb1")
    return psycopg2.connect(f"postgresql://{user}:{pwd}@{host}:{port}/{dbname}")


def json_serializer(obj):
    """JSON serializer for datetime objects."""
    if isinstance(obj, (date, datetime, time)):
        return obj.isoformat()
    return str(obj)


def export_database():
    """Exports all current database tables to epic_seed_data.json."""
    print("=" * 65)
    print("  EXPORTING FULL EPIC DATABASE TO SEED JSON")
    print("=" * 65)

    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=RealDictCursor)

    data = {}
    total_records = 0

    for table in TABLES_ORDER:
        try:
            order_clause = "ORDER BY id" if table != "role_permissions" else ""
            cur.execute(f'SELECT * FROM "{table}" {order_clause};')
            rows = cur.fetchall()
            # Convert RealDictRow to standard dict
            dict_rows = [dict(r) for r in rows]
            data[table] = dict_rows
            total_records += len(dict_rows)
            print(f"  [+] {table:<22} : {len(dict_rows):>5} records exported")
        except Exception as e:
            print(f"  [-] {table:<22} : Failed ({e})")
            conn.rollback()

    cur.close()
    conn.close()

    with open(SEED_DATA_JSON, "w", encoding="utf-8") as f:
        json.dump(data, f, default=json_serializer, indent=2, ensure_ascii=False)

    size_kb = os.path.getsize(SEED_DATA_JSON) / 1024
    print("=" * 65)
    print(f"SUCCESS: Exported {total_records} records across {len(data)} tables.")
    print(f"File saved to: {SEED_DATA_JSON} ({size_kb:.1f} KB)")
    print("=" * 65)


def seed_database(clean: bool = False):
    """Seeds the PostgreSQL database from epic_seed_data.json."""
    if not os.path.exists(SEED_DATA_JSON):
        print(f"Error: Seed file not found at {SEED_DATA_JSON}")
        print("Please run with --export first to generate seed file.")
        sys.exit(1)

    print("=" * 65)
    print(f"  SEEDING FULL EPIC DATABASE {'(CLEAN WIPE)' if clean else '(SAFE SEED)'}")
    print("=" * 65)

    # 1. Ensure all tables exist in database
    print("Step 1: Checking and creating schema tables if missing...")
    Base.metadata.create_all(bind=engine)
    print("  -> Schema is up to date.")

    # 2. Read seed data
    with open(SEED_DATA_JSON, "r", encoding="utf-8") as f:
        data = json.load(f)

    conn = get_db_connection()
    conn.autocommit = False
    cur = conn.cursor()

    try:
        # If clean, truncate tables in reverse foreign key order
        if clean:
            print("\nStep 2: Wiping existing records...")
            reverse_tables = list(reversed(TABLES_ORDER))
            for table in reverse_tables:
                cur.execute(f'TRUNCATE TABLE "{table}" CASCADE;')
                print(f"  -> Truncated: {table}")
            conn.commit()

        print("\nStep 3: Seeding records into tables...")
        total_seeded = 0

        for table in TABLES_ORDER:
            rows = data.get(table, [])
            if not rows:
                print(f"  [.] {table:<22} : 0 records (empty)")
                continue

            columns = list(rows[0].keys())
            col_names = ", ".join(f'"{c}"' for c in columns)
            placeholders = ", ".join(["%s"] * len(columns))

            # ON CONFLICT DO NOTHING / UPDATE
            if table == "role_permissions":
                conflict_clause = "ON CONFLICT DO NOTHING"
            elif "id" in columns:
                conflict_clause = 'ON CONFLICT ("id") DO NOTHING'
            else:
                conflict_clause = ""

            query = f'INSERT INTO "{table}" ({col_names}) VALUES ({placeholders}) {conflict_clause};'

            inserted_count = 0
            for r in rows:
                vals = [r.get(c) for c in columns]
                cur.execute(query, vals)
                if cur.rowcount > 0:
                    inserted_count += 1

            total_seeded += inserted_count
            print(f"  [+] {table:<22} : {inserted_count}/{len(rows)} records seeded")

        conn.commit()

        # Step 4: Reset postgres auto-increment sequences so future inserts don't collide
        print("\nStep 4: Updating ID auto-increment sequences...")
        for table in TABLES_ORDER:
            if table == "role_permissions":
                continue
            try:
                cur.execute(f"""
                    SELECT setval(
                        pg_get_serial_sequence('"{table}"', 'id'),
                        COALESCE(MAX(id), 1),
                        true
                    ) FROM "{table}";
                """)
                conn.commit()
            except Exception:
                conn.rollback()

        print("  -> All serial sequences synchronized.")

        print("\n" + "=" * 65)
        print(f"SUCCESS: Database seeding complete! Total inserted: {total_seeded}")
        print("=" * 65)

    except Exception as e:
        conn.rollback()
        print(f"\nERROR DURING SEEDING: {e}")
        raise
    finally:
        cur.close()
        conn.close()


def main():
    parser = argparse.ArgumentParser(description="EPIC Full Database Seeder & Exporter")
    parser.add_argument("--export", action="store_true", help="Export live database into seed JSON file")
    parser.add_argument("--clean", action="store_true", help="Wipe all tables before seeding")
    args = parser.parse_args()

    if args.export:
        export_database()
    else:
        seed_database(clean=args.clean)


if __name__ == "__main__":
    main()
