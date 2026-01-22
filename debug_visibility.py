from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.models.user import User, Role
from app.models.employee import Employee
from app.models.service_request import ServiceRequest
from app.models.service import AssignedService, Service
import os
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"

engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

print("--- USERS AND ROLES ---")
for user in session.query(User).all():
    print(f"ID: {user.id}, Name: {user.name}, Role: {user.role.name if user.role else 'N/A'}, EmployeeID: {user.employee.id if user.employee else 'None'}")

print("\n--- PENDING SERVICE REQUESTS ---")
for sr in session.query(ServiceRequest).filter(ServiceRequest.status != 'completed').all():
    emp_name = sr.employee.name if sr.employee else "Unassigned"
    print(f"ID: {sr.id}, Room: {sr.room.number if sr.room else '?'}, Type: {sr.request_type}, AssignedTo: {emp_name} (ID: {sr.employee_id})")

print("\n--- PENDING ASSIGNED SERVICES (2M offset) ---")
for asvc in session.query(AssignedService).filter(AssignedService.status != 'completed').all():
    emp_name = asvc.employee.name if asvc.employee else "Unassigned"
    svc_name = asvc.service.name if asvc.service else "?"
    print(f"ID: {asvc.id + 2000000}, Room: {asvc.room.number if asvc.room else '?'}, Type: {svc_name}, AssignedTo: {emp_name} (ID: {asvc.employee_id})")
