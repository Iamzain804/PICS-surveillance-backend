import os
from datetime import datetime
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

def generate_camera_excel(report_data):
    """
    Generate Excel file for Camera Processing Reports.
    Expects report_data to be a list of dictionaries.
    """
    try:
        wb = openpyxl.Workbook()
        ws = wb.active
        ws.title = "Camera Processing Report"

        # Styling definitions
        header_font = Font(name="Calibri", size=12, bold=True, color="FFFFFF")
        header_fill = PatternFill(start_color="2B6CB0", end_color="2B6CB0", fill_type="solid")
        header_alignment = Alignment(horizontal="center", vertical="center")
        
        cell_font = Font(name="Calibri", size=11)
        cell_alignment = Alignment(horizontal="left", vertical="center")
        center_alignment = Alignment(horizontal="center", vertical="center")
        
        thin_border = Border(
            left=Side(style='thin', color="CCCCCC"),
            right=Side(style='thin', color="CCCCCC"),
            top=Side(style='thin', color="CCCCCC"),
            bottom=Side(style='thin', color="CCCCCC")
        )

        headers = [
            "Video Name",
            "Branch",
            "Camera",
            "Processing Date",
            "Status",
            "In Detections",
            "Out Detections",
            "Total Events",
            "Recognized",
            "Accuracy",
            "Duration"
        ]

        # Write Headers
        for col_num, header_text in enumerate(headers, 1):
            cell = ws.cell(row=1, column=col_num, value=header_text)
            cell.font = header_font
            cell.fill = header_fill
            cell.alignment = header_alignment
            cell.border = thin_border

        # Write Data rows
        for row_num, row_data in enumerate(report_data, 2):
            cells = [
                ws.cell(row=row_num, column=1, value=row_data.get("video_name", "")),
                ws.cell(row=row_num, column=2, value=row_data.get("branch_name", "")),
                ws.cell(row=row_num, column=3, value=row_data.get("camera_name", "")),
                ws.cell(row=row_num, column=4, value=row_data.get("processing_date", "")),
                ws.cell(row=row_num, column=5, value=str(row_data.get("status", "")).capitalize()),
                ws.cell(row=row_num, column=6, value=row_data.get("checkin_detections", 0)),
                ws.cell(row=row_num, column=7, value=row_data.get("checkout_detections", 0)),
                ws.cell(row=row_num, column=8, value=row_data.get("total_detections", 0)),
                ws.cell(row=row_num, column=9, value=row_data.get("recognized_detections", 0)),
                ws.cell(row=row_num, column=10, value=row_data.get("accuracy_rate", "0%")),
                ws.cell(row=row_num, column=11, value=row_data.get("duration_formatted", str(row_data.get("processing_duration", 0))))
            ]
            
            for i, cell in enumerate(cells):
                cell.font = cell_font
                cell.border = thin_border
                if i >= 4: # Center align stats
                    cell.alignment = center_alignment
                else:
                    cell.alignment = cell_alignment

        # Auto-adjust column widths
        for col in ws.columns:
            max_length = 0
            column = col[0].column_letter 
            for cell in col:
                try: 
                    if len(str(cell.value)) > max_length:
                        max_length = len(cell.value)
                except:
                    pass
            adjusted_width = (max_length + 2)
            ws.column_dimensions[column].width = min(adjusted_width, 50)

        # Save the file
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"EPIC_Camera_Processing_Report_{timestamp}.xlsx"
        
        # Save in the same directory as the script
        output_dir = os.path.dirname(os.path.abspath(__file__))
        filepath = os.path.join(output_dir, filename)
        
        wb.save(filepath)
        return filepath
        
    except Exception as e:
        print(f"Error generating Camera Processing Excel: {e}")
        return None
