import sys
import json
from datetime import datetime, date

# Add the app directory to path
sys.path.append("/var/www/zeebull/ResortApp")

from app.database import SessionLocal
from app.models.employee import Employee, WorkingLog
from app.api.attendance import _calculate_duration

db = SessionLocal()

try:
    emp = db.query(Employee).filter(Employee.id == 26).first()
    print(f"Employee ID: {emp.id} | Name: {emp.name} | BranchID: {emp.branch_id}")
    
    working_logs = db.query(WorkingLog).filter(
        WorkingLog.employee_id == 26,
        WorkingLog.date >= date(2026, 6, 1),
        WorkingLog.date <= date(2026, 6, 30)
    ).all()
    print(f"\nLogs for June 2026: {len(working_logs)}")
    
    daily_hours = {}
    for log in working_logs:
        duration = _calculate_duration(log.date, log.check_in_time, log.check_out_time) or 0
        d_str = str(log.date)
        daily_hours[d_str] = daily_hours.get(d_str, 0) + duration
        
    print("Daily hours map:")
    for k, v in sorted(daily_hours.items()):
        print(f"  {k}: {v} hours")
        
    present_days = sum(1 for hours in daily_hours.values() if hours >= 4)
    print(f"\nPresent Days calculated: {present_days}")
    
except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()
