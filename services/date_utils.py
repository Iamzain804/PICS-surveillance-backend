"""
services/date_utils.py
----------------------
Convert a date_preset string into strict (start_dt, end_dt) datetime bounds.

Supported presets:
  today           → 00:00:00 … 23:59:59 of today
  this_week       → Monday 00:00:00 … Sunday 23:59:59 of current ISO week
  previous_week   → Monday 00:00:00 … Sunday 23:59:59 of last ISO week
  this_month      → 1st 00:00:00 … last-day 23:59:59 of current month
  previous_month  → 1st 00:00:00 … last-day 23:59:59 of previous month
  custom          → caller supplies start_date / end_date (YYYY-MM-DD strings)

Returns: (datetime, datetime)  - both timezone-naive, local wall-clock time.
Raises:  ValueError on unknown preset or unparseable custom dates.
"""

from datetime import datetime, timedelta, date
import calendar


_DATE_FMT = "%Y-%m-%d"


def _day_start(d: date) -> datetime:
    return datetime(d.year, d.month, d.day, 0, 0, 0)


def _day_end(d: date) -> datetime:
    return datetime(d.year, d.month, d.day, 23, 59, 59)


def _parse_date_str(s: str) -> date:
    """Parse YYYY-MM-DD string; raises ValueError on failure."""
    try:
        return datetime.strptime(s.strip(), _DATE_FMT).date()
    except (ValueError, AttributeError):
        raise ValueError(f"Invalid date string '{s}'. Expected format: YYYY-MM-DD")


def resolve_date_range(
    preset: str,
    start_date: str | None = None,
    end_date: str | None = None,
) -> tuple[datetime, datetime]:
    """
    Return (start_dt, end_dt) for the given preset.

    Parameters
    ----------
    preset      : one of today / this_week / previous_week /
                  this_month / previous_month / custom
    start_date  : required when preset == 'custom'  (YYYY-MM-DD)
    end_date    : required when preset == 'custom'  (YYYY-MM-DD)

    Returns
    -------
    (start_dt, end_dt) as naive datetime objects (00:00:00 … 23:59:59)
    """
    today = date.today()
    p = (preset or "today").strip().lower()

    if p == "today":
        return _day_start(today), _day_end(today)

    if p == "this_week":
        # weekday(): Monday=0, Sunday=6
        monday = today - timedelta(days=today.weekday())
        sunday = monday + timedelta(days=6)
        return _day_start(monday), _day_end(sunday)

    if p == "previous_week":
        monday_this = today - timedelta(days=today.weekday())
        sunday_prev = monday_this - timedelta(days=1)
        monday_prev = sunday_prev - timedelta(days=6)
        return _day_start(monday_prev), _day_end(sunday_prev)

    if p == "this_month":
        first = today.replace(day=1)
        last_day = calendar.monthrange(today.year, today.month)[1]
        last = today.replace(day=last_day)
        return _day_start(first), _day_end(last)

    if p == "previous_month":
        first_this = today.replace(day=1)
        last_prev = first_this - timedelta(days=1)
        first_prev = last_prev.replace(day=1)
        return _day_start(first_prev), _day_end(last_prev)

    if p == "custom":
        if not start_date or not end_date:
            raise ValueError("preset='custom' requires both start_date and end_date")
        s = _parse_date_str(start_date)
        e = _parse_date_str(end_date)
        if s > e:
            raise ValueError(f"start_date ({start_date}) must not be after end_date ({end_date})")
        return _day_start(s), _day_end(e)

    raise ValueError(
        f"Unknown preset '{preset}'. "
        "Valid values: today, this_week, previous_week, this_month, previous_month, custom"
    )
