from sqlalchemy.orm import joinedload
from app.database import SessionLocal
from app.models.employee import Employee, Leave, WorkingLog
import sys

db = SessionLocal()

print("\n\n" + "="*50)
print("TEST 1: Employee + User")
print("="*50)
try:
    emps = db.query(Employee).options(joinedload(Employee.user)).limit(1).all()
    print(f"SUCCESS: Found {len(emps)} employees")
except Exception as e:
    print(f"FAIL: {e}")

print("\n\n" + "="*50)
print("TEST 2: Leave")
print("="*50)
try:
    leaves = db.query(Leave).limit(1).all()
    print(f"SUCCESS: Found {len(leaves)} leaves")
except Exception as e:
    print(f"FAIL: {e}")

print("\n\n" + "="*50)
print("TEST 3: WorkingLog")
print("="*50)
try:
    logs = db.query(WorkingLog).limit(1).all()
    print(f"SUCCESS: Found {len(logs)} logs")
except Exception as e:
    print(f"FAIL: {e}")
    # Inspect table via SQL
    try:
        res = db.execute("SELECT * FROM working_logs LIMIT 0")
        print("Table columns:", res.keys())
    except Exception as e2:
        print(f"SQL FAIL: {e2}")

db.close()
