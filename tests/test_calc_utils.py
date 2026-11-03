"""
tests/test_calc_utils.py
Tests for services/calc_utils - all 5 calculation helpers.
"""

import pytest
from datetime import datetime
from services.calc_utils import (
    calc_net_work_hours,
    calc_late_arrival_minutes,
    calc_early_departure_minutes,
    calc_overtime_minutes,
    calc_break_duration_minutes,
)


# ═════════════════════════════════════════════════════════════════════════════
# calc_net_work_hours
# ═════════════════════════════════════════════════════════════════════════════

class TestNetWorkHours:

    def test_basic_string_timestamps(self):
        # 09:20 → 18:10 = 530 mins office, minus 45 break = 485
        result = calc_net_work_hours("2025-07-28 09:20:00", "2025-07-28 18:10:00", 45)
        assert result == 485

    def test_no_breaks(self):
        # 09:00 → 17:00 = 480 mins, no breaks
        result = calc_net_work_hours("2025-07-28 09:00:00", "2025-07-28 17:00:00", 0)
        assert result == 480

    def test_datetime_objects(self):
        ci = datetime(2025, 7, 28, 9, 0)
        co = datetime(2025, 7, 28, 17, 0)
        assert calc_net_work_hours(ci, co, 0) == 480

    def test_missing_checkout_returns_none(self):
        assert calc_net_work_hours("2025-07-28 09:00:00", None) is None

    def test_missing_checkin_returns_none(self):
        assert calc_net_work_hours(None, "2025-07-28 17:00:00") is None

    def test_both_none_returns_none(self):
        assert calc_net_work_hours(None, None) is None

    def test_empty_string_checkout_returns_none(self):
        assert calc_net_work_hours("2025-07-28 09:00:00", "") is None

    def test_break_minutes_default_zero(self):
        result = calc_net_work_hours("2025-07-28 09:00:00", "2025-07-28 17:00:00")
        assert result == 480

    def test_breaks_exceed_office_time_returns_negative(self):
        # 1 hour office, 90 min breaks → -30
        result = calc_net_work_hours("2025-07-28 09:00:00", "2025-07-28 10:00:00", 90)
        assert result == -30

    def test_exact_one_minute(self):
        result = calc_net_work_hours("2025-07-28 09:00:00", "2025-07-28 09:01:00", 0)
        assert result == 1

    def test_dd_mm_yyyy_format(self):
        result = calc_net_work_hours("28-07-2025 09:00:00", "28-07-2025 17:00:00", 0)
        assert result == 480

    def test_iso_format_with_T(self):
        result = calc_net_work_hours("2025-07-28T09:00:00", "2025-07-28T17:00:00", 0)
        assert result == 480


# ═════════════════════════════════════════════════════════════════════════════
# calc_late_arrival_minutes
# ═════════════════════════════════════════════════════════════════════════════

class TestLateArrival:

    def test_late_no_grace(self):
        # checked in 09:20, shift 09:00, grace 0 → 20 mins late
        result = calc_late_arrival_minutes("2025-07-28 09:20:00", "09:00", grace_minutes=0)
        assert result == 20

    def test_late_with_grace_still_late(self):
        # checked in 09:20, shift 09:00, grace 15 → 5 mins late
        result = calc_late_arrival_minutes("2025-07-28 09:20:00", "09:00", grace_minutes=15)
        assert result == 5

    def test_within_grace_returns_none(self):
        # checked in 09:10, shift 09:00, grace 15 → on time (within grace)
        result = calc_late_arrival_minutes("2025-07-28 09:10:00", "09:00", grace_minutes=15)
        assert result is None

    def test_on_time_returns_none(self):
        result = calc_late_arrival_minutes("2025-07-28 09:00:00", "09:00", grace_minutes=0)
        assert result is None

    def test_early_arrival_returns_none(self):
        result = calc_late_arrival_minutes("2025-07-28 08:45:00", "09:00", grace_minutes=0)
        assert result is None

    def test_missing_checkin_returns_none(self):
        assert calc_late_arrival_minutes(None, "09:00") is None

    def test_missing_shift_start_returns_none(self):
        assert calc_late_arrival_minutes("2025-07-28 09:20:00", None) is None

    def test_empty_shift_start_returns_none(self):
        assert calc_late_arrival_minutes("2025-07-28 09:20:00", "") is None

    def test_shift_start_with_am_pm(self):
        # "09:00 AM" same as "09:00"
        result = calc_late_arrival_minutes("2025-07-28 09:30:00", "09:00 AM", grace_minutes=0)
        assert result == 30

    def test_pm_shift_start(self):
        # afternoon shift 02:00 PM = 14:00, checked in 14:20 → 20 mins late
        result = calc_late_arrival_minutes("2025-07-28 14:20:00", "02:00 PM", grace_minutes=0)
        assert result == 20

    def test_grace_exactly_equal_returns_none(self):
        # checked in 09:15, shift 09:00, grace 15 → exactly at grace boundary → not late
        result = calc_late_arrival_minutes("2025-07-28 09:15:00", "09:00", grace_minutes=15)
        assert result is None


# ═════════════════════════════════════════════════════════════════════════════
# calc_early_departure_minutes
# ═════════════════════════════════════════════════════════════════════════════

class TestEarlyDeparture:

    def test_left_30_mins_early(self):
        result = calc_early_departure_minutes("2025-07-28 17:30:00", "18:00")
        assert result == 30

    def test_left_on_time_returns_none(self):
        result = calc_early_departure_minutes("2025-07-28 18:00:00", "18:00")
        assert result is None

    def test_left_after_shift_end_returns_none(self):
        result = calc_early_departure_minutes("2025-07-28 18:30:00", "18:00")
        assert result is None

    def test_missing_checkout_returns_none(self):
        assert calc_early_departure_minutes(None, "18:00") is None

    def test_missing_shift_end_returns_none(self):
        assert calc_early_departure_minutes("2025-07-28 17:30:00", None) is None

    def test_empty_shift_end_returns_none(self):
        assert calc_early_departure_minutes("2025-07-28 17:30:00", "") is None

    def test_pm_shift_end(self):
        # shift ends 06:00 PM = 18:00, left at 17:00 → 60 mins early
        result = calc_early_departure_minutes("2025-07-28 17:00:00", "06:00 PM")
        assert result == 60

    def test_datetime_object(self):
        co = datetime(2025, 7, 28, 17, 30)
        result = calc_early_departure_minutes(co, "18:00")
        assert result == 30

    def test_left_1_minute_early(self):
        result = calc_early_departure_minutes("2025-07-28 17:59:00", "18:00")
        assert result == 1


# ═════════════════════════════════════════════════════════════════════════════
# calc_overtime_minutes
# ═════════════════════════════════════════════════════════════════════════════

class TestOvertime:

    def test_60_mins_overtime(self):
        result = calc_overtime_minutes("2025-07-28 19:00:00", "18:00")
        assert result == 60

    def test_left_on_time_returns_none(self):
        result = calc_overtime_minutes("2025-07-28 18:00:00", "18:00")
        assert result is None

    def test_left_early_returns_none(self):
        result = calc_overtime_minutes("2025-07-28 17:30:00", "18:00")
        assert result is None

    def test_missing_checkout_returns_none(self):
        assert calc_overtime_minutes(None, "18:00") is None

    def test_missing_shift_end_returns_none(self):
        assert calc_overtime_minutes("2025-07-28 19:00:00", None) is None

    def test_empty_shift_end_returns_none(self):
        assert calc_overtime_minutes("2025-07-28 19:00:00", "") is None

    def test_pm_shift_end(self):
        # shift ends 06:00 PM = 18:00, left 19:30 → 90 mins OT
        result = calc_overtime_minutes("2025-07-28 19:30:00", "06:00 PM")
        assert result == 90

    def test_datetime_object(self):
        co = datetime(2025, 7, 28, 19, 0)
        result = calc_overtime_minutes(co, "18:00")
        assert result == 60

    def test_1_minute_overtime(self):
        result = calc_overtime_minutes("2025-07-28 18:01:00", "18:00")
        assert result == 1


# ═════════════════════════════════════════════════════════════════════════════
# calc_break_duration_minutes
# ═════════════════════════════════════════════════════════════════════════════

class TestBreakDuration:

    def test_35_minute_break(self):
        result = calc_break_duration_minutes(
            "2025-07-28 13:00:00", "2025-07-28 13:35:00"
        )
        assert result == 35

    def test_60_minute_break(self):
        result = calc_break_duration_minutes(
            "2025-07-28 13:00:00", "2025-07-28 14:00:00"
        )
        assert result == 60

    def test_missing_break_start_returns_none(self):
        assert calc_break_duration_minutes(None, "2025-07-28 13:35:00") is None

    def test_missing_break_end_returns_none(self):
        assert calc_break_duration_minutes("2025-07-28 13:00:00", None) is None

    def test_both_none_returns_none(self):
        assert calc_break_duration_minutes(None, None) is None

    def test_empty_string_returns_none(self):
        assert calc_break_duration_minutes("", "2025-07-28 13:35:00") is None

    def test_datetime_objects(self):
        bs = datetime(2025, 7, 28, 13, 0)
        be = datetime(2025, 7, 28, 13, 45)
        assert calc_break_duration_minutes(bs, be) == 45

    def test_reversed_timestamps_returns_zero(self):
        # break_end before break_start → clamped to 0 (clock skew guard)
        result = calc_break_duration_minutes(
            "2025-07-28 13:35:00", "2025-07-28 13:00:00"
        )
        assert result == 0

    def test_zero_duration_break(self):
        result = calc_break_duration_minutes(
            "2025-07-28 13:00:00", "2025-07-28 13:00:00"
        )
        assert result == 0

    def test_1_minute_break(self):
        result = calc_break_duration_minutes(
            "2025-07-28 13:00:00", "2025-07-28 13:01:00"
        )
        assert result == 1

    def test_dd_mm_yyyy_format(self):
        result = calc_break_duration_minutes(
            "28-07-2025 13:00:00", "28-07-2025 13:30:00"
        )
        assert result == 30
