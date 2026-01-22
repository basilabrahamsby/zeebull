
import sys
import os
from sqlalchemy import create_engine, text
from datetime import datetime

# Setup DB connection (copying logic from check_alphi.py but adapted)
# For this environment, we can likely import directly if we setup sys.path
sys.path.append(os.path.join(os.getcwd(), 'ResortApp'))

from app.database import SessionLocal
from app.models.employee import Employee, WorkingLog
from app.models.user import User

def check_status():
    db = SessionLocal()
    try:
        print(f"Checking status for 'alphi' at {datetime.now()}")
        
        # 1. Find User/Employee
        # Try finding by name first
        employees = db.query(Employee).filter(Employee.name.ilike('%alphi%')).all()
        
        if not employees:
            print("No employee found with name containing 'alphi'")
            # Try user email
            users = db.query(User).filter(User.email.ilike('%alphi%')).all()
            for u in users:
                emp = db.query(Employee).filter(Employee.user_id == u.id).first()
                if emp:
                    employees.append(emp)
        
        if not employees:
            print("No employee found via name or email.")
            return

        for emp in employees:
            print(f"\n--- Employee: {emp.name} (ID: {emp.id}) ---")
            print(f"Role: {emp.role}")
            
            # 2. Check Working Logs
            logs = db.query(WorkingLog).filter(WorkingLog.employee_id == emp.id).order_by(WorkingLog.date.desc(), WorkingLog.check_in_time.desc()).limit(5).all()
            
            print(f"Latest 5 Working Logs:")
            open_log_found = False
            for log in logs:
                status = "OPEN (CLOCKED IN)" if log.check_out_time is None else "CLOSED"
                print(f"  [ID: {log.id}] Date: {log.date} | In: {log.check_in_time} | Out: {log.check_out_time} | Status: {status}")
                
                if log.check_out_time is None:
                    open_log_found = True
            
            if open_log_found:
                print(f"\nResult: Employee {emp.name} SHOULD be 'On Duty'.")
            else:
                print(f"\nResult: Employee {emp.name} is 'Off Duty' (No open logs found).")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_status()
