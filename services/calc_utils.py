"""
services/calc_utils.py
----------------------
Pure calculation helpers for Attendance and Break reports.
All functions are stateless - no DB access, no side effects.

Conventions
-----------
- Time strings accepted: "HH:MM", "HH:MM:SS", "HH:MM AM/PM"
- datetime objects accepted wherever a timestamp is needed
- All minute values are integers (floor division)
- Functions return None (not 0) when a value is genuinely missing/unknown
  so callers can distinguish "zero minutes late" from "no data"
"""

from datetime import datetime
from typing import Optional


# ─────────────────────────────────────────────────────────────────────────────
# Internal helpers
# ─────────────────────────────────────────────────────────────────────────────

def _to_datetime(val) -> Optional[datetime]:
    """
    Accept a datetime or a timestamp string in common formats.
    Returns None if val is falsy or unparseable - never raises.
    """
    if val is None:
        return None
    if isinstance(val, datetime):
        return val
    if not isinstance(val, str):
        return None

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
    return None


def _hhmm_to_minutes(t_str: str) -> Optional[int]:
    """
    Convert a time string ("HH:MM", "HH:MM:SS", "09:00 AM") to total minutes
    since midnight.  Returns None on failure - never raises.
    """
    if not t_str:
        return None
    try:
        parts = t_str.strip().split()
        time_part = parts[0]
        ampm = parts[1].upper() if len(parts) > 1 else None

        segments = time_part.split(":")
        h = int(segments[0])
        m = int(segments[1]) if len(segments) > 1 else 0

        if ampm == "PM" and h != 12:
            h += 12
        elif ampm == "AM" and h == 12:
            h = 0

        return h * 60 + m
    except Exception:
        return None


# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

def calc_net_work_hours(
    check_in,
    check_out,
    break_minutes: int = 0,
) -> Optional[int]:
    """
    Net work minutes = (check_out − check_in) − break_minutes.

    Parameters
    ----------
    check_in        : datetime or timestamp string
    check_out       : datetime or timestamp string - may be None/missing
    break_minutes   : total break duration already computed (default 0)

    Returns
    -------
    int   - net minutes worked  (can be negative if breaks exceed office time)
    None  - check_out is missing / unparseable
    """
    ci = _to_datetime(check_in)
    co = _to_datetime(check_out)

    if ci is None:
        return None
    if co is None:
        return None  # Missing Check-Out - caller decides how to label this

    office_mins = int((co - ci).total_seconds() // 60)
    return office_mins - break_minutes


def calc_late_arrival_minutes(
    check_in,
    shift_start_time: str,
    grace_minutes: int = 0,
) -> Optional[int]:
    """
    Minutes the employee arrived late past (shift_start + grace period).

    Returns
    -------
    int > 0   - late by this many minutes
    None      - check_in or shift_start_time is missing/unparseable,
                OR employee arrived on time / early
    """
    ci = _to_datetime(check_in)
    shift_start_mins = _hhmm_to_minutes(shift_start_time)

    if ci is None or shift_start_mins is None:
        return None

    checkin_mins = ci.hour * 60 + ci.minute
    late = checkin_mins - (shift_start_mins + grace_minutes)
    return late if late > 0 else None


def calc_early_arrival_minutes(
    check_in,
    shift_start_time: str,
) -> Optional[int]:
    """
    Minutes the employee arrived before shift_start_time.

    Returns
    -------
    int > 0   - arrived early by this many minutes
    None      - check_in or shift_start_time is missing/unparseable,
                OR employee arrived on time / late
    """
    ci = _to_datetime(check_in)
    shift_start_mins = _hhmm_to_minutes(shift_start_time)

    if ci is None or shift_start_mins is None:
        return None

    checkin_mins = ci.hour * 60 + ci.minute
    early = shift_start_mins - checkin_mins
    return early if early > 0 else None



def calc_early_departure_minutes(
    check_out,
    shift_end_time: str,
) -> Optional[int]:
    """
    Minutes the employee left before shift_end_time.

    Returns
    -------
    int > 0   - left early by this many minutes
    None      - check_out or shift_end_time is missing/unparseable,
                OR employee left on time / after shift end
    """
    co = _to_datetime(check_out)
    shift_end_mins = _hhmm_to_minutes(shift_end_time)

    if co is None or shift_end_mins is None:
        return None

    checkout_mins = co.hour * 60 + co.minute
    early = shift_end_mins - checkout_mins
    return early if early > 0 else None


def calc_overtime_minutes(
    check_out,
    shift_end_time: str,
) -> Optional[int]:
    """
    Minutes worked beyond shift_end_time.

    Returns
    -------
    int > 0   - overtime minutes
    None      - check_out or shift_end_time is missing/unparseable,
                OR employee left before / exactly at shift end
    """
    co = _to_datetime(check_out)
    shift_end_mins = _hhmm_to_minutes(shift_end_time)

    if co is None or shift_end_mins is None:
        return None

    checkout_mins = co.hour * 60 + co.minute
    ot = checkout_mins - shift_end_mins
    return ot if ot > 0 else None


def calc_break_duration_minutes(
    break_start,
    break_end,
) -> Optional[int]:
    """
    Duration of a single break session in minutes.

    Parameters
    ----------
    break_start : datetime or timestamp string
    break_end   : datetime or timestamp string

    Returns
    -------
    int >= 0  - break duration in minutes
    None      - either timestamp is missing/unparseable
    """
    bs = _to_datetime(break_start)
    be = _to_datetime(break_end)

    if bs is None or be is None:
        return None

    duration = int((be - bs).total_seconds() // 60)
    return max(duration, 0)  # guard against clock skew / reversed order
