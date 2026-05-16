import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), ".")))
from app.database import SessionLocal
from app.models.employee import Employee

db = SessionLocal()
try:
    emp = db.query(Employee).filter(Employee.id == 5).first()
    if emp:
        print(f"Employee found: {emp.name}, Branch: {emp.branch_id}")
    else:
        print("Employee with ID 5 not found.")
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
