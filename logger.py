import sys
import os
from datetime import datetime

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from database.database import SessionLocal, SystemLog

def system_log(message: str, level: str = "info", module: str = "system", log_time=None):
    """
    Logs a message to the database and prints it to the console.
    Level can be: info, warn, error, success, pipeline1, pipeline2, etc.
    log_time can be a datetime object or string. If None, uses current time.
    """
    if log_time is None:
        dt = datetime.now()
    elif isinstance(log_time, str):
        try:
            dt = datetime.strptime(log_time, "%d-%m-%Y %H:%M:%S")
        except ValueError:
            dt = datetime.now()
    else:
        dt = log_time
        
    # 1. Print to console for real-time visibility in terminals
    timestamp_str = dt.strftime("%H:%M:%S")
    print(f"[{timestamp_str}] [{level.upper()}] [{module.upper()}] {message}")

    # 2. Save to centralized database
    try:
        db = SessionLocal()
        log_entry = SystemLog(
            timestamp=dt,
            level=level,
            module=module,
            message=message
        )
        db.add(log_entry)
        db.commit()
    except Exception as e:
        print(f"[ERROR] Failed to save log to DB: {e}")
    finally:
        try:
            db.close()
        except:
            pass
