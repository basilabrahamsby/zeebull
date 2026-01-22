from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.service import AssignedService
from app.models.user import User
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

user = session.query(User).filter(User.email == 'alphi@orchid.com').first()
emp_id = user.employee.id if user.employee else None

print(f"Alphi Employee ID: {emp_id}")

tasks = session.query(AssignedService).filter(AssignedService.employee_id == emp_id).all()
print(f"Tasks assigned to Alphi: {len(tasks)}")
for t in tasks:
    print(f"  - ID: {t.id + 2000000}, Room: {t.room.number if t.room else '?'}, Status: {t.status}")

unassigned = session.query(AssignedService).filter(AssignedService.employee_id == None).all()
print(f"Unassigned tasks: {len(unassigned)}")
for t in unassigned:
    print(f"  - ID: {t.id + 2000000}, Room: {t.room.number if t.room else '?'}, Status: {t.status}")
