"""

Generate Excel Attendance & Break Time Report

==============================================

Generates a multi-sheet Excel report in the exact required format.
- Each STAFF gets their own styled worksheet tab.
- Pairs 'breakin' (Break In) and 'breakout' (Break Out) events per STAFF.

- Each employee gets their own styled worksheet tab.

- Pairs 'breakin' (Break In) and 'breakout' (Break Out) events per employee.

- Calculates exact break durations and formats headers with professional styling (#2B6CB0).

"""



import sys

import os

import openpyxl

from openpyxl.styles import Font, PatternFill, Alignment, Border, Side

from openpyxl.utils import get_column_letter
try:
    from openpyxl.worksheet.properties import OutlineProperties
except Exception:
    OutlineProperties = None

from datetime import datetime, timedelta
import math



# Add parent directory to path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))



from database.database import SessionLocal, Event, Video, Staff, Branch, Camera, Department





def parse_datetime(dt_str):

    """Parse timestamp string into datetime object."""

    if not dt_str:

        return None

    formats = [

        "%d-%m-%Y %H:%M:%S",

        "%d/%m/%Y %H:%M:%S",

        "%Y-%m-%d %H:%M:%S",

        "%d-%m-%Y %H.%M.%S"

    ]

    for fmt in formats:

        try:

            return datetime.strptime(dt_str, fmt)

        except ValueError:

            continue

    return None





def cluster_events(events, merge_window_seconds=180, pick_mode="first"):

    """

    Groups events that occur within `merge_window_seconds` (e.g. 3 minutes) of each other

    into a single representative event to prevent duplicate rows for a single entry/exit occurrence.

    - pick_mode='first': Uses earliest event in cluster (ideal for Break In / Entry)

    - pick_mode='last': Uses latest event in cluster (ideal for Break Out / Exit)

    """

    if not events:

        return []

        

    sorted_events = sorted(events, key=lambda x: parse_datetime(x.timestamp) or datetime.min)

    

    clusters = []

    current_cluster = [sorted_events[0]]

    

    for ev in sorted_events[1:]:

        last_in_cluster_dt = parse_datetime(current_cluster[-1].timestamp)

        current_dt = parse_datetime(ev.timestamp)

        

        if last_in_cluster_dt and current_dt:

            diff = (current_dt - last_in_cluster_dt).total_seconds()

            if diff <= merge_window_seconds:

                current_cluster.append(ev)

                continue

                

        clusters.append(current_cluster)

        current_cluster = [ev]

        

    if current_cluster:

        clusters.append(current_cluster)

        

    result = []

    for cl in clusters:

        if pick_mode == "first":

            result.append(cl[0])

        elif pick_mode == "last":

            result.append(cl[-1])

            

    return result





def format_duration(seconds):



    """Format total seconds into HH:MM:SS string."""

    if seconds is None or seconds < 0:

        return "--"

    total_sec = int(seconds)

    hours = total_sec // 3600

    minutes = (total_sec % 3600) // 60

    secs = total_sec % 60

    return f"{hours:02d}:{minutes:02d}:{secs:02d}"





def build_unified_employee_timeline(emp_evs, min_break_duration_seconds=0, merge_window_seconds=180):
    """
    State-Machine Break-Pairing Algorithm for Perfect Break Durations.
    ===================================================================
    - Chronologically sorts employee camera events.
    - Merges consecutive same-role events within `merge_window_seconds` (180s) to eliminate camera flicker/multiple detection noise.
    - State Machine transitions:
        • OUTSIDE_BREAK (0) + 'breakin'  -> IN_BREAK (1), record Break In timestamp
        • IN_BREAK (1)      + 'breakout' -> OUTSIDE_BREAK (0), record Break Out timestamp & compute EXACT duration!
        • Handles unpaired Break In or Break Out events gracefully with '--'.
    """
    if not emp_evs:
        return []

    # 1. Parse and sort all valid timestamped events
    parsed = []
    for ev in emp_evs:
        dt = parse_datetime(ev.timestamp)
        if dt:
            role = (ev.camera_role or "").lower()
            clean_role = "breakin" if role in ["breakin", "checkin"] else "breakout"
            parsed.append({
                "dt": dt,
                "role": clean_role,
                "emp_id": ev.employee_id or "-",
                "emp_name": ev.employee_name or "-",
                "raw_event": ev
            })

    parsed.sort(key=lambda x: x["dt"])
    if not parsed:
        return []

    # 2. Cooldown Clustering: Merge same-role events within merge_window_seconds (180s)
    clustered = []
    for item in parsed:
        if not clustered:
            clustered.append(item.copy())
        else:
            prev = clustered[-1]
            diff = (item["dt"] - prev["dt"]).total_seconds()
            if diff <= merge_window_seconds and item["role"] == prev["role"]:
                if item["role"] == "breakout":
                    prev["dt"] = item["dt"]  # Extend breakout to latest time
            else:
                clustered.append(item.copy())

    # 3. State-Machine Pairing Logic
    MAX_BREAK_DURATION_SECS = 7200  # 2 hours — auto-close if exceeded (camera likely missed breakout)
    sessions = []
    state = 0  # 0: OUTSIDE_BREAK, 1: IN_BREAK
    active_breakin = None

    for ev in clustered:
        if ev["role"] == "breakin":
            if state == 1 and active_breakin is not None:
                gap_secs = (ev["dt"] - active_breakin["dt"]).total_seconds()
                if gap_secs > MAX_BREAK_DURATION_SECS:
                    # Gap exceeds max → camera missed the breakout → auto-close previous break
                    sessions.append({
                        "sort_dt": active_breakin["dt"],
                        "emp_id": active_breakin["emp_id"],
                        "emp_name": active_breakin["emp_name"],
                        "date": active_breakin["dt"].strftime("%d-%m-%Y"),
                        "break_in": active_breakin["dt"].strftime("%H:%M:%S"),
                        "break_out": "--",
                        "duration_sec": None
                    })
                    # Start new break
                    state = 1
                    active_breakin = ev
                else:
                    # Still within max duration — same break, ignore repeated breakin
                    continue
            else:
                state = 1
                active_breakin = ev

        elif ev["role"] == "breakout":
            if state == 1 and active_breakin is not None:
                dur_sec = (ev["dt"] - active_breakin["dt"]).total_seconds()
                if dur_sec > MAX_BREAK_DURATION_SECS:
                    # Breakout too far from breakin — auto-close as Missed, skip this breakout
                    sessions.append({
                        "sort_dt": active_breakin["dt"],
                        "emp_id": active_breakin["emp_id"],
                        "emp_name": active_breakin["emp_name"],
                        "date": active_breakin["dt"].strftime("%d-%m-%Y"),
                        "break_in": active_breakin["dt"].strftime("%H:%M:%S"),
                        "break_out": "--",
                        "duration_sec": None
                    })
                    state = 0
                    active_breakin = None
                elif dur_sec >= min_break_duration_seconds:
                    # Perfect Pair Found!
                    sessions.append({
                        "sort_dt": active_breakin["dt"],
                        "emp_id": active_breakin["emp_id"],
                        "emp_name": active_breakin["emp_name"],
                        "date": active_breakin["dt"].strftime("%d-%m-%Y"),
                        "break_in": active_breakin["dt"].strftime("%H:%M:%S"),
                        "break_out": ev["dt"].strftime("%H:%M:%S"),
                        "duration_sec": dur_sec
                    })
                    state = 0
                    active_breakin = None
                else:
                    # Too short — still close the break
                    state = 0
                    active_breakin = None
            else:
                # Do not register breakout if breakin has not occurred
                pass

    # Close trailing unpaired breakin if any
    if state == 1 and active_breakin is not None:
        sessions.append({
            "sort_dt": active_breakin["dt"],
            "emp_id": active_breakin["emp_id"],
            "emp_name": active_breakin["emp_name"],
            "date": active_breakin["dt"].strftime("%d-%m-%Y"),
            "break_in": active_breakin["dt"].strftime("%H:%M:%S"),
            "break_out": "--",
            "duration_sec": None
        })

    sessions.sort(key=lambda x: x["sort_dt"])
    return sessions









def generate_report_file(filters: dict = None, report_data: dict = None, db=None, output_filename: str = None):

    """Wrapper function for API endpoint report generation."""

    if filters is None:

        filters = {}

    if output_filename is None:

        today_str = datetime.now().strftime("%Y%m%d_%H%M%S")

        report_type = filters.get("report_type", "attendance")

        output_filename = os.path.normpath(

            os.path.join(os.path.dirname(__file__), "..", f"Report_{report_type}_{today_str}.xlsx")

        )

    return generate_attendance_excel_report(filters=filters, report_data=report_data, output_filename=output_filename, db=db)





def generate_attendance_excel_report(filters: dict = None, report_data: dict = None, output_filename: str = None, db=None):

    """

    Generate Excel Attendance & Break Report file based on UI filters and report_data.

    """

    if filters is None:

        filters = {}

        

    close_db = False

    if db is None:

        db = SessionLocal()

        close_db = True

    

    try:

        if not report_data:

            print("  [EXCEL] No report_data provided.")

            if close_db: db.close()

            return None



        res = report_data
        summary_list = res.get("data") or res.get("summary_list") or []
        summary_stats = res.get("summary") or res.get("summary_stats") or {}
        metadata = res.get("metadata", {})

        # If date objects are strings or None, parse datetime
        today_date = datetime.now().date()
        date_from_dt = res.get("date_from_dt") or today_date
        date_to_dt = res.get("date_to_dt") or today_date
        if isinstance(date_from_dt, str):
            try: date_from_dt = datetime.strptime(date_from_dt, "%Y-%m-%d").date()
            except Exception: date_from_dt = today_date
        if isinstance(date_to_dt, str):
            try: date_to_dt = datetime.strptime(date_to_dt, "%Y-%m-%d").date()
            except Exception: date_to_dt = today_date

        report_type = filters.get("report_type", "attendance")
        is_break_report = (report_type == "break")
        camera_id = filters.get("camera_id")
        status_filter = filters.get("status_filter", "all")

        # Read metadata flags produced by api_server
        show_branch_col = metadata.get("show_branch_column", True)
        show_dept_col = metadata.get("show_department_column", True)

        # Resolve selected branch name robustly
        from database.database import Branch
        raw_branch = (
            filters.get("branch_name")
            or metadata.get("selected_branch")
            or summary_stats.get("branch_name")
            or filters.get("branch_id")
            or "All Branches"
        )
        selected_branch = str(raw_branch).strip()
        if selected_branch.isdigit() and db:
            try:
                b_row = db.query(Branch).filter(Branch.id == int(selected_branch)).first()
                if b_row:
                    selected_branch = b_row.name
            except Exception:
                pass
        elif selected_branch.lower() in ["all", "none", "", "all branches"]:
            # If all rows belong to the same single branch, use that branch's name
            if summary_list:
                uniq_branches = {r.get("branch_name") for r in summary_list if r.get("branch_name")}
                if len(uniq_branches) == 1:
                    selected_branch = list(uniq_branches)[0]
                else:
                    selected_branch = "All Branches"
            else:
                selected_branch = "All Branches"

        selected_dept = (
            filters.get("department_name")
            or metadata.get("selected_department")
            or summary_stats.get("department_name")
            or filters.get("department")
            or "All Departments"
        )
        selected_dept = str(selected_dept).strip()
        if selected_dept.lower() in ["all", "none", "", "all departments"]:
            if summary_list:
                uniq_depts = {r.get("department") for r in summary_list if r.get("department")}
                if len(uniq_depts) == 1:
                    selected_dept = list(uniq_depts)[0]
                else:
                    selected_dept = "All Departments"
            else:
                selected_dept = "All Departments"
        report_mode = metadata.get("report_mode", "daily")
        is_multi_date = (report_mode == "range")

        # Create Excel workbook
        wb = openpyxl.Workbook()
        wb.remove(wb.active)

        # ── Style Definitions ────────────────────────────────────────────────
        font_meta_label = Font(name="Calibri", size=10, bold=True, color="4A5568")
        font_meta_val   = Font(name="Calibri", size=10, color="2D3748")
        font_title_sm   = Font(name="Calibri", size=12, bold=True, color="1A365D")

        header_fill = PatternFill(start_color="2B6CB0", end_color="2B6CB0", fill_type="solid")
        header_font = Font(name="Calibri", size=11, bold=True, color="FFFFFF")

        alt_row_fill  = PatternFill(start_color="F7FAFC", end_color="F7FAFC", fill_type="solid")
        total_row_fill = PatternFill(start_color="EDF2F7", end_color="EDF2F7", fill_type="solid")
        total_row_font = Font(name="Calibri", size=11, bold=True, color="1A202C")
        data_font      = Font(name="Calibri", size=10, color="2D3748")

        thin_border_side = Side(border_style="thin", color="CBD5E0")
        thin_border = Border(
            left=thin_border_side, right=thin_border_side,
            top=thin_border_side, bottom=thin_border_side
        )
        align_left   = Alignment(horizontal="left",   vertical="center", wrap_text=True)
        align_center = Alignment(horizontal="center", vertical="center", wrap_text=True)

        gen_date_str = datetime.now().strftime("%d %b %Y")
        gen_time_str = datetime.now().strftime("%I:%M %p")
        report_date_str = datetime.now().strftime("%d-%b-%Y")

        print(f"\n  [EXCEL] Generating {report_type.upper()} Excel Report "
              f"({'Range' if is_multi_date else 'Daily'}) with {len(summary_list)} STAFFs...")

        # ── Report Period Label ──────────────────────────────────────────────
        report_period_label = summary_stats.get("date_range") or summary_stats.get("report_period", "Current Date")
        activity_type_label = "Break Activity Report" if is_break_report else "Attendance Activity Report"

        # ════════════════════════════════════════════════════════════════════
        # SHEET 1: SUMMARY REPORT (Header: Professional, print-friendly)
        # ════════════════════════════════════════════════════════════════════
        ws_sum = wb.create_sheet(title="Summary Report")
        ws_sum.views.sheetView[0].showGridLines = True
        ws_sum.sheet_view.showRowColHeaders = True
        # Ensure outline groups are shown collapsed by default; set outline properties
        try:
            ws_sum.sheet_properties.outlinePr = OutlineProperties(summaryBelow=False, summaryRight=False)
        except Exception:
            # older openpyxl versions may not have OutlineProperties or may behave differently
            pass

        # Header colors / fills
        header_label_fill = PatternFill(start_color="EBF4FF", end_color="EBF4FF", fill_type="solid")
        header_bg_fill    = PatternFill(start_color="F0F4F8", end_color="F0F4F8", fill_type="solid")
        title_fill        = PatternFill(start_color="153E75", end_color="153E75", fill_type="solid")

        # ── Build dynamic column lists ───────────────────────────────────────
        sum_headers = ["#", "Staff ID", "Staff Name", "Branch", "Department"]
        col_keys    = ["__seq__", "staff_id", "name", "branch_name", "department"]

        if is_break_report:
            if is_multi_date:  # Range Break
                sum_headers.append("Break Schedule")
                col_keys.append("allocated_break_window")
                sum_headers += ["Working Days", "Total Break Hours", "Total Break Count", "Total Break Exceeded", "Total Off Window",
                                "Avg Break Duration", "Longest Break", "Shortest Break",
                                "Avg Breaks/Day"]
                col_keys    += ["working_days", "total_break_hours", "total_break_count", "total_break_exceeded", "total_off_window",
                                "avg_break_duration", "longest_break", "shortest_break",
                                "avg_breaks_per_day"]
            else:  # Daily Break - summary only (exact format: First Break-In, Last Break-Out, Break Count, Total Break Duration)
                sum_headers += ["First Break-In", "Last Break-Out", "Break Count", "Total Break Duration"]
                col_keys    += ["first_breakin", "last_breakout", "break_count", "total_break_duration"]
        else:
            sum_headers.append("Shift")
            col_keys.append("shift")
            if is_multi_date:  # Range Attendance
                sum_headers += ["Working Days", "Present Days", "Absent Days",
                                "Late Days", "Total Break Duration", "Net Working Hours",
                                "Total Early Departure", "Total Overtime", "Attendance %", "Status"]
                col_keys    += ["working_days", "present_days", "absent_days",
                                "late_days", "total_break_hours", "net_work_hours",
                                "early_departure_days", "overtime_days", "attendance_pct", "attendance_status"]
            else:  # Daily Attendance
                sum_headers += ["Status", "Check-In", "Check-Out",
                                "Office Hours", "Total Break Hours", "Net Working Hours",
                                "Late By", "Early Departure", "Overtime"]
                col_keys    += ["attendance_status", "check_in", "check_out",
                                "office_hours", "total_break_hours", "net_work_hours",
                                "late_by", "early_departure_by", "overtime"]

        # Determine a reasonable merge width for the title based on number of summary columns
        total_cols = max(12, len(sum_headers))
        last_col_letter = get_column_letter(total_cols)

        # Row 1: Merged Title
        ws_sum.merge_cells(f"A1:{last_col_letter}1")
        title_cell = ws_sum.cell(row=1, column=1, value=f"{activity_type_label}")
        title_cell.font = Font(name="Calibri", size=16, bold=True, color="FFFFFF")
        title_cell.fill = title_fill
        title_cell.alignment = Alignment(horizontal="center", vertical="center")
        ws_sum.row_dimensions[1].height = 30

        # Rows 2-5: Two-column metadata block (left and right columns)
        meta_left = [
            ("Company Name:", "Hanif Jewellers"),
            ("Branch:", selected_branch),
            ("Department:", selected_dept),
        ]
        meta_right = [
            ("Report Period:", report_period_label),
            ("Generated Date:", gen_date_str),
            ("Generated Time:", gen_time_str),
        ]

        # Write metadata into a 2-column layout: Left labels in A/B, Right labels in D/E
        start_meta_row = 2
        for i in range(max(len(meta_left), len(meta_right))):
            row_idx = start_meta_row + i
            # Left label/value
            if i < len(meta_left):
                lbl, val = meta_left[i]
                lc = ws_sum.cell(row=row_idx, column=1, value=lbl)
                lc.font = font_meta_label
                lc.fill = header_label_fill
                lc.alignment = Alignment(horizontal="left", vertical="center")

                vc = ws_sum.cell(row=row_idx, column=2, value=val)
                vc.font = font_meta_val
                vc.fill = header_bg_fill
                vc.alignment = Alignment(horizontal="left", vertical="center")
            # Right label/value
            if i < len(meta_right):
                lbl_r, val_r = meta_right[i]
                rc = ws_sum.cell(row=row_idx, column=4, value=lbl_r)
                rc.font = font_meta_label
                rc.fill = header_label_fill
                rc.alignment = Alignment(horizontal="left", vertical="center")

                rv = ws_sum.cell(row=row_idx, column=5, value=val_r)
                rv.font = font_meta_val
                rv.fill = header_bg_fill
                rv.alignment = Alignment(horizontal="left", vertical="center")

            ws_sum.row_dimensions[row_idx].height = 18

        # Activity Type under metadata (row after meta)
        at_row = start_meta_row + max(len(meta_left), len(meta_right))
        ac = ws_sum.cell(row=at_row, column=1, value="Activity Type:")
        ac.font = font_meta_label
        ac.fill = header_label_fill
        ac.alignment = Alignment(horizontal="left", vertical="center")
        av = ws_sum.cell(row=at_row, column=2, value=activity_type_label)
        av.font = font_meta_val
        av.fill = header_bg_fill
        av.alignment = Alignment(horizontal="left", vertical="center")
        ws_sum.row_dimensions[at_row].height = 18

        # Add a subtle border around metadata block
        meta_start = 2
        meta_end = at_row
        thin_side = Side(border_style="thin", color="CBD5E0")
        meta_border = Border(left=thin_side, right=thin_side, top=thin_side, bottom=thin_side)
        for r in range(meta_start, meta_end + 1):
            for c in [1,2,4,5]:
                ws_sum.cell(row=r, column=c).border = meta_border

        # Small gap before table
        gap_row = meta_end + 1
        ws_sum.row_dimensions[gap_row].height = 6

        # Freeze below the header block + column-header row (row 9)
        ws_sum.freeze_panes = "A10"

        # Page setup for A4 printing
        ws_sum.page_setup.paperSize = 9  # A4
        ws_sum.page_setup.orientation = "landscape"
        ws_sum.page_margins.left = 0.5
        ws_sum.page_margins.right = 0.5
        ws_sum.page_margins.top = 0.6
        ws_sum.page_margins.bottom = 0.6
        ws_sum.print_options.horizontalCentered = True

        # ── Write column header row (row 9) ──────────────────────────────────
        TABLE_HEADER_ROW = 9
        DATA_START_ROW   = 10

        for col_num, h_text in enumerate(sum_headers, 1):
            cell = ws_sum.cell(row=TABLE_HEADER_ROW, column=col_num, value=h_text)
            cell.fill = header_fill
            cell.font = header_font
            cell.alignment = align_center
            cell.border = thin_border
        ws_sum.row_dimensions[TABLE_HEADER_ROW].height = 22

        # ── Write data rows ──────────────────────────────────────────────────
        current_row = DATA_START_ROW
        for seq, entry in enumerate(summary_list, 1):
            row_fill = alt_row_fill if seq % 2 == 0 else None

            if is_break_report and not is_multi_date:
                sessions = entry.get("break_sessions", [])
                if sessions and len(sessions) > 0:
                    first_bi = "--"
                    for bs in sessions:
                        bi = bs.get("breakin", "")
                        if bi and bi not in ("—", "--", None):
                            first_bi = bi
                            break
                    entry["first_breakin"] = first_bi

                    last_valid_bo = "--"
                    for bs in reversed(sessions):
                        bo = bs.get("breakout", "")
                        if bo and bo not in ("—", "--", "Missed", "Active", None):
                            last_valid_bo = bo
                            break
                    entry["last_breakout"] = last_valid_bo
                else:
                    entry["first_breakin"] = "--"
                    entry["last_breakout"] = "--"

            # Write the main summary row for the employee
            for col_num, key in enumerate(col_keys, 1):
                if key == "__seq__":
                    val = seq
                else:
                    val = entry.get(key)
                    if val is None:
                        val = "-"
                cell = ws_sum.cell(row=current_row, column=col_num, value=val)
                cell.font = data_font
                cell.border = thin_border
                cell.alignment = align_left if col_num in [3] else align_center
                if row_fill:
                    cell.fill = row_fill
            ws_sum.row_dimensions[current_row].height = 18
            current_row += 1

            # Insert grouped Break Sessions (accordion-style rows) under each employee for Break reports
            if is_break_report and not is_multi_date:
                break_sessions = entry.get("break_sessions", []) or []
                break_col_idx = 5  # Exactly under Department (Col 5)

                sub_hdrs = ["Break #", "Break In", "Break Out", "Break Duration", "Location"]
                total_table_cols = len(col_keys)

                # Sub-header row for break table
                sub_start = current_row

                # Write empty padded cells for columns before break details
                for cidx in range(1, break_col_idx):
                    cell = ws_sum.cell(row=current_row, column=cidx, value="")
                    cell.font = data_font
                    cell.border = thin_border
                    cell.alignment = align_center
                    if row_fill:
                        cell.fill = row_fill

                # Write break detail sub-headers
                for i, h in enumerate(sub_hdrs):
                    ch = ws_sum.cell(row=current_row, column=break_col_idx + i, value=h)
                    ch.font = Font(name="Calibri", size=9, bold=True, color="1A365D")
                    ch.fill = PatternFill(start_color="E2E8F0", end_color="E2E8F0", fill_type="solid")
                    ch.alignment = align_center
                    ch.border = thin_border

                ws_sum.row_dimensions[current_row].height = 18
                current_row += 1

                if break_sessions:
                    for idx, bs in enumerate(break_sessions, 1):
                        dur_str = bs.get("duration") or "--"
                        if dur_str == "Active":
                            dur_str = "--"
                        bi = bs.get("breakin") or "--"
                        if bi in ("—", "None", ""): bi = "--"
                        bo = bs.get("breakout") or "--"
                        if bo in ("—", "None", ""): bo = "--"
                        loc = bs.get("sub_location") or "Rooftop Cafeteria"

                        for cidx in range(1, break_col_idx):
                            cell = ws_sum.cell(row=current_row, column=cidx, value="")
                            cell.font = data_font
                            cell.border = thin_border
                            cell.alignment = align_center
                            if row_fill:
                                cell.fill = row_fill

                        vals = [idx, bi, bo, dur_str, loc]
                        for i, v in enumerate(vals):
                            c = ws_sum.cell(row=current_row, column=break_col_idx + i, value=v)
                            c.font = data_font
                            c.border = thin_border
                            c.alignment = align_center if i < 4 else align_left
                            if row_fill:
                                cell.fill = row_fill

                        ws_sum.row_dimensions[current_row].height = 18
                        current_row += 1
                else:
                    # No breaks row
                    for cidx in range(1, break_col_idx):
                        cell = ws_sum.cell(row=current_row, column=cidx, value="")
                        cell.font = data_font
                        cell.border = thin_border
                        cell.alignment = align_center
                        if row_fill:
                            cell.fill = row_fill

                    c = ws_sum.cell(row=current_row, column=break_col_idx, value="No Breaks")
                    c.font = data_font
                    c.alignment = align_center
                    c.border = thin_border
                    ws_sum.merge_cells(start_row=current_row, start_column=break_col_idx, end_row=current_row, end_column=len(col_keys))
                    if row_fill:
                        for cc in range(break_col_idx, len(col_keys) + 1):
                            ws_sum.cell(row=current_row, column=cc).fill = row_fill

                    ws_sum.row_dimensions[current_row].height = 18
                    current_row += 1

                sub_end = current_row - 1
                if sub_end >= sub_start:
                    try:
                        ws_sum.row_dimensions.group(sub_start, sub_end, hidden=True, outline_level=1)
                    except Exception:
                        for r in range(sub_start, sub_end + 1):
                            ws_sum.row_dimensions[r].outlineLevel = 1
                            ws_sum.row_dimensions[r].hidden = True

        # Ensure sheet outline (+) button sits next to master summary row
        try:
            if OutlineProperties is not None:
                ws_sum.sheet_properties.outlinePr = OutlineProperties(summaryBelow=False, summaryRight=False)
        except Exception:
            pass

        # ── Summary stats footer ─────────────────────────────────────────────
        current_row += 1
        ws_sum.cell(row=current_row, column=1, value="TOTALS").font = font_title_sm
        current_row += 1
        ws_sum.cell(row=current_row, column=1, value="Total Staff:").font = font_meta_label
        ws_sum.cell(row=current_row, column=2, value=summary_stats.get("total_employees") or len(summary_list)).font = font_meta_val
        if is_break_report:
            current_row += 1
            ws_sum.cell(row=current_row, column=1, value="Total Breaks:").font = font_meta_label
            ws_sum.cell(row=current_row, column=2, value=summary_stats.get("grand_total_breaks", 0)).font = font_meta_val
            current_row += 1
            ws_sum.cell(row=current_row, column=1, value="Total Break Hours:").font = font_meta_label
            ws_sum.cell(row=current_row, column=2, value=summary_stats.get("grand_total_break_hours", "00 hrs 00 mins")).font = font_meta_val
        else:
            current_row += 1
            ws_sum.cell(row=current_row, column=1, value="Present:").font = font_meta_label
            ws_sum.cell(row=current_row, column=2, value=summary_stats.get("total_present", 0)).font = font_meta_val
            current_row += 1
            ws_sum.cell(row=current_row, column=1, value="Absent:").font = font_meta_label
            ws_sum.cell(row=current_row, column=2, value=summary_stats.get("total_absent", 0)).font = font_meta_val
            current_row += 1
            ws_sum.cell(row=current_row, column=1, value="Late:").font = font_meta_label
            ws_sum.cell(row=current_row, column=2, value=summary_stats.get("total_late", 0)).font = font_meta_val

        # ── Auto-fit column widths across ALL columns ─────────────────────────
        total_cols_all = len(col_keys)

        for col_idx in range(1, total_cols_all + 1):
            col_letter = get_column_letter(col_idx)
            max_len = 0
            for r in range(TABLE_HEADER_ROW, current_row):
                cell = ws_sum.cell(row=r, column=col_idx)
                if cell and cell.value is not None:
                    val = str(cell.value).strip()
                    if val:
                        max_len = max(max_len, len(val))

            min_width = 14
            if col_idx == 1:
                min_width = 6
            elif col_idx == 2:  # Staff ID
                min_width = 12
            elif col_idx == 3:  # Staff Name
                min_width = 28
            elif col_idx == 4:  # Branch
                min_width = 19
            elif col_idx == 5:  # Department / Break #
                min_width = 28
            elif col_idx in [6, 7]:  # First Break-In / Last Break-Out
                min_width = 18
            elif col_idx == 8:  # Break Count / Break Duration
                min_width = 18
            elif col_idx == 9:  # Total Break Duration / Location
                min_width = 24

            final_w = max(max_len + 4, min_width)
            ws_sum.column_dimensions[col_letter].width = final_w

        # ── Apply wrap_text and set approximate row heights based on computed column widths
        for r in range(TABLE_HEADER_ROW, current_row):
            # preserve header row height
            if r == TABLE_HEADER_ROW:
                ws_sum.row_dimensions[r].height = 22
                # still set wrap on header cells
            max_lines = 1
            for cidx in range(1, total_cols + 1):
                cell = ws_sum.cell(row=r, column=cidx)
                val = "" if cell.value is None else str(cell.value)
                # set wrap and alignment (left for name and location columns, center otherwise)
                horiz = 'left' if cidx in [3] else 'center'
                cell.alignment = Alignment(horizontal=horiz, vertical='center', wrap_text=True)
                if val.strip():
                    # approximate characters per line using column width (heuristic)
                    col_w = ws_sum.column_dimensions[get_column_letter(cidx)].width or 14
                    chars_per_line = max(10, int(col_w))
                    lines = math.ceil(len(val) / chars_per_line)
                    max_lines = max(max_lines, lines)
            # set row height (approx 15 points per line)
            row_h = max(16, max_lines * 15)
            # avoid changing metadata/title rows above DATA_START_ROW
            if r >= DATA_START_ROW:
                ws_sum.row_dimensions[r].height = row_h







        # Output filename

        if not output_filename:

            today_str = datetime.now().strftime("%Y-%m-%d")

            output_filename = os.path.join(

                os.path.dirname(__file__), "..", f"Attendance_Report_{today_str}.xlsx"

            )

            

        output_filename = os.path.normpath(output_filename)

        

        try:

            wb.save(output_filename)

        except PermissionError:

            time_suffix = datetime.now().strftime("%H%M%S")

            output_filename = os.path.join(

                os.path.dirname(__file__), "..", f"Attendance_Report_{today_str}_{time_suffix}.xlsx"

            )

            output_filename = os.path.normpath(output_filename)

            wb.save(output_filename)

            

        print(f"  [EXCEL SUCCESS] Attendance Report saved to: {output_filename}\n")

        return output_filename



    except Exception as e:

        print(f"  [EXCEL ERROR] Failed to generate report: {e}")

        import traceback

        traceback.print_exc()

        return None

    finally:

        db.close()





if __name__ == "__main__":

    generate_attendance_excel_report()

