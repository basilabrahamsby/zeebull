from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.service import AssignedService
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

asvc = session.query(AssignedService).filter(AssignedService.id == 1).first()
if asvc:
    print(f"Current EmpID: {asvc.employee_id}")
    asvc.employee_id = None
    session.commit()
    print("Updated to None")
else:
    print("Not found")
