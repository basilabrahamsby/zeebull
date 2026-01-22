from sqlalchemy.orm import joinedload
from app.database import SessionLocal
from app.models.employee import Employee, Leave, WorkingLog

db = SessionLocal()

print("Testing Employee query...")
try:
    emps = db.query(Employee).options(joinedload(Employee.user)).all()
    print(f"Success! Found {len(emps)} employees")
except Exception as e:
    print(f"FAIL Employee: {e}")

print("Testing Leave query...")
try:
    leaves = db.query(Leave).all()
    print(f"Success! Found {len(leaves)} leaves")
except Exception as e:
    print(f"FAIL Leave: {e}")

print("Testing WorkingLog query...")
try:
    logs = db.query(WorkingLog).all()
    print(f"Success! Found {len(logs)} logs")
except Exception as e:
    print(f"FAIL WorkingLog: {e}")

db.close()
