from sqlalchemy import text, inspect
from sqlalchemy.orm import joinedload
from app.database import SessionLocal, engine
from app.models.employee import Employee, Leave, WorkingLog
import sys

db = SessionLocal()

print("--- START TEST ---")

print("\nTEST 1: Employee + User")
try:
    emps = db.query(Employee).options(joinedload(Employee.user)).limit(1).all()
    print(f"SUCCESS: Found {len(emps)} employees")
except Exception as e:
    print(f"FAIL: {e}")

print("\nTEST 2: Leave")
try:
    leaves = db.query(Leave).limit(1).all()
    print(f"SUCCESS: Found {len(leaves)} leaves")
except Exception as e:
    print(f"FAIL: {e}")

print("\nTEST 3: WorkingLog")
try:
    logs = db.query(WorkingLog).limit(1).all()
    print(f"SUCCESS: Found {len(logs)} logs")
except Exception as e:
    print(f"FAIL: {e}")
    # Inspect table via Inspector
    try:
        insp = inspect(engine)
        cols = insp.get_columns("working_logs")
        print("INSPECT COLUMNS:", [c['name'] for c in cols])
    except Exception as e2:
        print(f"INSPECT FAIL: {e2}")

db.close()
print("--- END TEST ---")
