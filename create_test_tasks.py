from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.service import AssignedService, Service
from app.models.room import Room
from app.models.employee import Employee
from datetime import datetime

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

# 1. Create a task assigned to someone else (EmpID 5 - Harry)
harry_task = AssignedService(
    service_id=1,  # Assuming service 1 exists
    employee_id=5, # Harry
    room_id=1,     # Assuming room 1 exists
    assigned_at=datetime.utcnow(),
    status='pending'
)
session.add(harry_task)
session.commit()
print(f"Created pending task for Harry (ID: {harry_task.id})")

# 2. Create a task assigned to Alphi (EmpID 4)
alphi_task = AssignedService(
    service_id=1,
    employee_id=4, # Alphi
    room_id=1,
    assigned_at=datetime.utcnow(),
    status='pending'
)
session.add(alphi_task)
session.commit()
print(f"Created pending task for Alphi (ID: {alphi_task.id})")
