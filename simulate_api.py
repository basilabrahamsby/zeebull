from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.api.service_request import get_service_requests
from app.models.user import User
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

user = session.query(User).filter(User.email == 'alphi@orchid.com').first()
# Mock FastAPI Depends
results = get_service_requests(db=session, current_user=user)

print(f"API RESULTS COUNT: {len(results)}")
for r in results:
    print(f"ID: {r.get('id')} | Room: {r.get('room_number')} | Type: {r.get('type')} | Emp: {r.get('employee_name')} | IsAssigned: {r.get('is_assigned_service')}")
