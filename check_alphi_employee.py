#!/usr/bin/env python3
"""Check alphi's employee ID"""

import sys
sys.path.insert(0, '/var/www/inventory/ResortApp')

from app.database import SessionLocal
from app.models.employee import Employee
from app.models.user import User

db = SessionLocal()

try:
    user = db.query(User).filter(User.email == 'alphi@orchid.com').first()
    if user:
        print(f"User ID: {user.id}")
        employee = db.query(Employee).filter(Employee.user_id == user.id).first()
        if employee:
            print(f"Employee ID: {employee.id}")
            print(f"Employee Name: {employee.name}")
        else:
            print("Employee record not found")
    else:
        print("User not found")
finally:
    db.close()
