
import sys
import os

current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.employee import Employee
from app.models.user import User

db = SessionLocal()
emp = db.query(Employee).filter(Employee.id == 12).first()
if emp:
    print(f"Employee 12: {emp.name}, User ID: {emp.user_id}")
    u = db.query(User).filter(User.id == emp.user_id).first()
    if u:
        print(f"User {emp.user_id}: {u.username}")
    else:
        print(f"User {emp.user_id} NOT FOUND")
else:
    print("Employee 12 NOT FOUND")
db.close()
