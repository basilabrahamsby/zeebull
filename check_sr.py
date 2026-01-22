from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.service_request import ServiceRequest
from app.models.room import Room
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

rs = session.query(ServiceRequest).join(Room).filter(Room.number.in_(["101", "103"])).all()
print(f"SERVICE REQUESTS COUNT: {len(rs)}")
for r in rs:
    print(f"ID: {r.id} | Room: {r.room.number} | Type: {r.request_type} | Status: {r.status} | EmpID: {r.employee_id}")
