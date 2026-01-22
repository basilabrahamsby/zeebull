#!/usr/bin/env python3
"""Check today's attendance records"""

import sys
sys.path.insert(0, '/var/www/inventory/ResortApp')

from app.database import SessionLocal
from app.models.employee import Employee, Attendance
from datetime import date

db = SessionLocal()

try:
    # Get today's attendance
    today = date.today()
    attendances = db.query(Attendance).filter(Attendance.date == today).all()
    
    print(f"Today's Attendance ({today}):")
    print("-" * 60)
    
    if not attendances:
        print("No attendance records found for today")
    else:
        for a in attendances:
            employee = db.query(Employee).filter(Employee.id == a.employee_id).first()
            emp_name = employee.name if employee else "Unknown"
            print(f"Employee: {emp_name} (ID: {a.employee_id})")
            print(f"  Status: {a.status}")
            print(f"  Clock In: {a.clock_in_time}")
            print(f"  Clock Out: {a.clock_out_time}")
            print()
            
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
