from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.service import AssignedService, Service
from app.models.room import Room
from app.models.employee import Employee
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

print("--- ALL ASSIGNED SERVICES ---")
asvcs = session.query(AssignedService).all()
for a in asvcs:
    print(f"ID: {a.id} | Room: {a.room.number if a.room else '?'} | Service: {a.service.name if a.service else '?'} | Status: {a.status} | EmpID: {a.employee_id} | EmpName: {a.employee.name if a.employee else 'None'}")
