import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.service import AssignedService
from app.models.employee import Employee
from app.models.room import Room

db = SessionLocal()

print("--- Querying all Assigned Services ---")
assigned = db.query(AssignedService).join(Employee).all()
for a in assigned:
    print(f"ID: {a.id}, Emp: {a.employee.name} (ID: {a.employee.id}), Room: {a.room.number if a.room else 'None'}, Status: {a.status}, Assigned At: {a.assigned_at}, Completed At: {a.completed_at}")

print("\n--- Querying Keshav specifically ---")
keshav = db.query(Employee).filter(Employee.name.ilike('%keshav%')).first()
if keshav:
    print(f"Keshav Employee ID: {keshav.id}")
    asv_k = db.query(AssignedService).filter(AssignedService.employee_id == keshav.id).all()
    for a in asv_k:
        print(f"  Keshav Task ID: {a.id}, Room: {a.room.number if a.room else 'None'}, Status: {a.status}, Assigned: {a.assigned_at}, Completed: {a.completed_at}")
else:
    print("Keshav not found")

db.close()
