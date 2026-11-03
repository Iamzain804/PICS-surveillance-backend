"""
tests/test_date_utils.py
Tests for services/date_utils.resolve_date_range()
"""

import pytest
import calendar
from datetime import date, datetime, timedelta
from unittest.mock import patch

from services.date_utils import resolve_date_range


# ── helpers ──────────────────────────────────────────────────────────────────

def _today():
    return date.today()


# ── today ─────────────────────────────────────────────────────────────────────

class TestToday:
    def test_start_is_midnight(self):
        s, _ = resolve_date_range("today")
        assert s.hour == 0 and s.minute == 0 and s.second == 0

    def test_end_is_end_of_day(self):
        _, e = resolve_date_range("today")
        assert e.hour == 23 and e.minute == 59 and e.second == 59

    def test_same_date(self):
        s, e = resolve_date_range("today")
        assert s.date() == e.date() == _today()

    def test_case_insensitive(self):
        s1, e1 = resolve_date_range("TODAY")
        s2, e2 = resolve_date_range("Today")
        assert s1 == s2 and e1 == e2


# ── this_week ─────────────────────────────────────────────────────────────────

class TestThisWeek:
    def test_start_is_monday(self):
        s, _ = resolve_date_range("this_week")
        assert s.weekday() == 0  # Monday

    def test_end_is_sunday(self):
        _, e = resolve_date_range("this_week")
        assert e.weekday() == 6  # Sunday

    def test_span_is_7_days(self):
        s, e = resolve_date_range("this_week")
        assert (e.date() - s.date()).days == 6

    def test_today_is_within_range(self):
        s, e = resolve_date_range("this_week")
        today_dt = datetime.combine(_today(), datetime.min.time())
        assert s <= today_dt <= e

    def test_start_midnight_end_eod(self):
        s, e = resolve_date_range("this_week")
        assert s.hour == 0 and s.second == 0
        assert e.hour == 23 and e.minute == 59 and e.second == 59


# ── previous_week ─────────────────────────────────────────────────────────────

class TestPreviousWeek:
    def test_start_is_monday(self):
        s, _ = resolve_date_range("previous_week")
        assert s.weekday() == 0

    def test_end_is_sunday(self):
        _, e = resolve_date_range("previous_week")
        assert e.weekday() == 6

    def test_span_is_7_days(self):
        s, e = resolve_date_range("previous_week")
        assert (e.date() - s.date()).days == 6

    def test_previous_week_ends_before_this_week_starts(self):
        s_this, _ = resolve_date_range("this_week")
        _, e_prev = resolve_date_range("previous_week")
        assert e_prev.date() < s_this.date()

    def test_gap_between_weeks_is_zero_days(self):
        """Sunday of prev week + 1 day == Monday of this week."""
        s_this, _ = resolve_date_range("this_week")
        _, e_prev = resolve_date_range("previous_week")
        assert (s_this.date() - e_prev.date()).days == 1


# ── this_month ────────────────────────────────────────────────────────────────

class TestThisMonth:
    def test_start_is_first_of_month(self):
        s, _ = resolve_date_range("this_month")
        assert s.day == 1

    def test_end_is_last_of_month(self):
        _, e = resolve_date_range("this_month")
        today = _today()
        expected_last = calendar.monthrange(today.year, today.month)[1]
        assert e.day == expected_last

    def test_same_month_and_year(self):
        today = _today()
        s, e = resolve_date_range("this_month")
        assert s.month == today.month == e.month
        assert s.year == today.year == e.year

    def test_today_within_range(self):
        s, e = resolve_date_range("this_month")
        today_dt = datetime.combine(_today(), datetime.min.time())
        assert s <= today_dt <= e


# ── previous_month ────────────────────────────────────────────────────────────

class TestPreviousMonth:
    def test_start_is_first_of_month(self):
        s, _ = resolve_date_range("previous_month")
        assert s.day == 1

    def test_end_is_last_of_month(self):
        s, e = resolve_date_range("previous_month")
        expected_last = calendar.monthrange(s.year, s.month)[1]
        assert e.day == expected_last

    def test_previous_month_ends_before_this_month_starts(self):
        s_this, _ = resolve_date_range("this_month")
        _, e_prev = resolve_date_range("previous_month")
        assert e_prev.date() < s_this.date()

    def test_month_rollback_from_january(self):
        """When today is in January, previous month must be December of prior year."""
        fake_today = date(2025, 1, 15)
        with patch("services.date_utils.date") as mock_date:
            mock_date.today.return_value = fake_today
            mock_date.side_effect = lambda *a, **kw: date(*a, **kw)
            s, e = resolve_date_range("previous_month")
        assert s.month == 12 and s.year == 2024
        assert e.month == 12 and e.day == 31 and e.year == 2024


# ── custom ────────────────────────────────────────────────────────────────────

class TestCustom:
    def test_basic_range(self):
        s, e = resolve_date_range("custom", "2025-01-01", "2025-01-31")
        assert s.date() == date(2025, 1, 1)
        assert e.date() == date(2025, 1, 31)

    def test_start_midnight(self):
        s, _ = resolve_date_range("custom", "2025-06-01", "2025-06-30")
        assert s.hour == 0 and s.minute == 0 and s.second == 0

    def test_end_eod(self):
        _, e = resolve_date_range("custom", "2025-06-01", "2025-06-30")
        assert e.hour == 23 and e.minute == 59 and e.second == 59

    def test_single_day_range(self):
        s, e = resolve_date_range("custom", "2025-07-28", "2025-07-28")
        assert s.date() == e.date() == date(2025, 7, 28)

    def test_missing_start_date_raises(self):
        with pytest.raises(ValueError, match="requires both"):
            resolve_date_range("custom", None, "2025-01-31")

    def test_missing_end_date_raises(self):
        with pytest.raises(ValueError, match="requires both"):
            resolve_date_range("custom", "2025-01-01", None)

    def test_reversed_dates_raise(self):
        with pytest.raises(ValueError, match="must not be after"):
            resolve_date_range("custom", "2025-12-31", "2025-01-01")

    def test_invalid_date_format_raises(self):
        with pytest.raises(ValueError):
            resolve_date_range("custom", "28-07-2025", "2025-07-31")


# ── unknown preset ────────────────────────────────────────────────────────────

class TestUnknownPreset:
    def test_unknown_raises_value_error(self):
        with pytest.raises(ValueError, match="Unknown preset"):
            resolve_date_range("last_year")

    def test_empty_string_falls_back_to_today(self):
        """Empty string is falsy → (preset or 'today') → behaves like 'today'."""
        s, e = resolve_date_range("")
        assert s.date() == e.date() == _today()
