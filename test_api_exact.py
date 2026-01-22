from sqlalchemy import text
from sqlalchemy.orm import joinedload
from app.database import SessionLocal
from app.models.employee import Employee, Leave, WorkingLog
from datetime import date
import sys

# Flush stdout to ensure order
sys.stdout.reconfigure(line_buffering=True)

db = SessionLocal()
today = date(2026, 1, 20) # Use the date from the error log

print("--- EXECUTING API QUERIES ---")

print("1. Fetching Employees with User...")
try:
    employees = db.query(Employee).options(joinedload(Employee.user)).all()
    print(f"SUCCESS: Fetched {len(employees)} employees.")
except Exception as e:
    print(f"FAIL: {e}")

print("2. Fetching Active Leaves...")
try:
    active_leaves = db.query(Leave).filter(
        Leave.from_date <= today,
        Leave.to_date >= today
    ).all()
    print(f"SUCCESS: Fetched {len(active_leaves)} active leaves.")
except Exception as e:
    print(f"FAIL: {e}")

print("3. Fetching Today Working Logs...")
try:
    today_logs = db.query(WorkingLog).filter(
        WorkingLog.date == today
    ).all()
    print(f"SUCCESS: Fetched {len(today_logs)} logs.")
except Exception as e:
    print(f"FAIL: {e}")

db.close()
print("--- FINISHED ---")
