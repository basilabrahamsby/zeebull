#!/usr/bin/env python3
"""Restore admin system status and create missing employee records for actual staff members."""

import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee
from app.models.branch import Branch
from datetime import date
from sqlalchemy import text

db = SessionLocal()

try:
    # 1. Restore Super Admin (Zeebull Administrator) to NOT editable state by removing its employee record
    admin_user = db.query(User).filter(User.email == 'admin@orchid.com').first()
    if admin_user:
        admin_employee = db.query(Employee).filter(Employee.user_id == admin_user.id).first()
        if admin_employee:
            db.delete(admin_employee)
            print("Successfully deleted Zeebull Administrator employee record (Super Admin is now NOT editable again).")

    # 2. Get first branch ID
    branch_res = db.execute(text("SELECT id FROM branches LIMIT 1")).first()
    if not branch_res:
        print("Error: No branches found in the database.")
        sys.exit(1)
    branch_id = branch_res[0]

    # 3. Define missing employees to create
    missing_staff = [
        {"email": "basil@gmail.com", "role": "Manager"},
        {"email": "alphi@gmail.com", "role": "waiter"},
        {"email": "appu@gmail.com", "role": "kitchen"},
        {"email": "sanithsanu.ss@gmail.com", "role": "operation manager"}
    ]

    for staff in missing_staff:
        user = db.query(User).filter(User.email == staff["email"]).first()
        if not user:
            print(f"User with email '{staff['email']}' not found. Skipping...")
            continue
        
        # Check if they already have an employee record
        existing_emp = db.query(Employee).filter(Employee.user_id == user.id).first()
        if existing_emp:
            print(f"Employee record already exists for '{user.name}' ({staff['email']}).")
            continue
        
        # Create Employee Record
        emp = Employee(
            name=user.name,
            role=staff["role"],
            salary=0.0,
            join_date=date.today(),
            user_id=user.id,
            branch_id=branch_id,
            paid_leave_balance=12,
            sick_leave_balance=12,
            long_leave_balance=5,
            wellness_leave_balance=5
        )
        db.add(emp)
        print(f"Created employee record for '{user.name}' (Email: {staff['email']}, Role: {staff['role']}).")

    db.commit()
    print("Database updates completed successfully!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
    db.rollback()
finally:
    db.close()
