from sqlalchemy import create_engine, or_
from sqlalchemy.orm import sessionmaker, joinedload
from app.models.user import User, Role
from app.models.employee import Employee
from app.models.service import AssignedService, Service
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# Mocking the logic in service_request.py
target_user = session.query(User).filter(User.email == 'alphi@orchid.com').first()
user_role = target_user.role.name.lower() if target_user.role else "guest"
is_admin = user_role in ["admin", "manager", "owner", "superadmin"]
current_employee_id = target_user.employee.id if target_user.employee else None

print(f"User: {target_user.email}, Role: {user_role}, Admin: {is_admin}, EmpID: {current_employee_id}")

assigned_query = session.query(AssignedService).options(
    joinedload(AssignedService.service),
    joinedload(AssignedService.room),
    joinedload(AssignedService.employee)
)

if not is_admin:
    if current_employee_id:
        assigned_query = assigned_query.filter(
            or_(AssignedService.employee_id == current_employee_id, AssignedService.employee_id == None)
        )
    else:
        assigned_query = assigned_query.filter(AssignedService.employee_id == None)

from app.models.service import ServiceStatus
assigned_query = assigned_query.filter(AssignedService.status.notin_([ServiceStatus.completed, ServiceStatus.cancelled]))

results = assigned_query.all()
print(f"RESULTS COUNT: {len(results)}")
for r in results:
    print(f"ID: {r.id}, Room: {r.room.number if r.room else '?'}, EmpID: {r.employee_id}")
