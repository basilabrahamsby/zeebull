from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.service import AssignedService
from app.models.service_request import ServiceRequest
from app.models.checkout import CheckoutRequest
from app.models.user import User
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

user = session.query(User).filter(User.email == 'alphi@orchid.com').first()
emp_id = user.employee.id if user.employee else None
print(f"Alphi Employee ID: {emp_id}")

def audit(model, name, emp_id):
    assigned = session.query(model).filter(model.employee_id == emp_id).all()
    print(f"--- {name} assigned to Alphi: {len(assigned)} ---")
    for t in assigned:
        rm = t.room.number if hasattr(t, 'room') and t.room else '?'
        print(f"  - ID: {t.id}, Room: {rm}, Status: {t.status}")
    
    unassigned = session.query(model).filter(model.employee_id == None).all()
    print(f"--- {name} unassigned: {len(unassigned)} ---")
    for t in unassigned:
        rm = t.room.number if hasattr(t, 'room') and t.room else '?'
        print(f"  - ID: {t.id}, Room: {rm}, Status: {t.status}")

audit(AssignedService, "AssignedService", emp_id)
audit(ServiceRequest, "ServiceRequest", emp_id)
audit(CheckoutRequest, "CheckoutRequest", emp_id)
