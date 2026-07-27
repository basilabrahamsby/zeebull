import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.employee import Employee, EmployeeLocationHistory
from sqlalchemy import text

db = SessionLocal()
try:
    print("Checking employees table live coordinates:")
    emps = db.query(Employee).filter(Employee.is_active == True).all()
    for e in emps:
        print(f"ID: {e.id}, Name: {e.name}, Role: {e.role}, Lat: {e.latitude}, Lng: {e.longitude}, Last Update: {e.last_location_update}")
        
    print("\nChecking location history entries count:")
    count = db.query(EmployeeLocationHistory).count()
    print(f"Total location history records in DB: {count}")
    if count > 0:
        latest = db.query(EmployeeLocationHistory).order_by(EmployeeLocationHistory.timestamp.desc()).limit(10).all()
        for idx, l in enumerate(latest):
            print(f"  {idx}: Emp ID {l.employee_id}, Lat: {l.latitude}, Lng: {l.longitude}, Time: {l.timestamp}")
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
