#!/usr/bin/env python3
"""Create an employee record for the default admin user in the database."""

import os
import sys

# Add ResortApp directory to system path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee
from app.models.branch import Branch
from datetime import date

db = SessionLocal()

try:
    # 1. Find the admin user
    admin_user = db.query(User).filter(User.email == 'admin@orchid.com').first()
    if not admin_user:
        print("Error: admin@orchid.com user not found in the users table.")
        sys.exit(1)
    
    print(f"Found admin user: ID={admin_user.id}, Name='{admin_user.name}'")

    # 2. Check if an employee record already exists for this user
    existing_emp = db.query(Employee).filter(Employee.user_id == admin_user.id).first()
    if existing_emp:
        print(f"Employee record already exists for admin: ID={existing_emp.id}, Name='{existing_emp.name}', Role='{existing_emp.role}'")
        sys.exit(0)

    # 3. Fetch the first branch to associate with the admin
    from sqlalchemy import text
    branch_res = db.execute(text("SELECT id FROM branches LIMIT 1")).first()
    if not branch_res:
        print("Error: No branches found in the database. Please seed branches first.")
        sys.exit(1)
    branch_id = branch_res[0]
    print(f"Associating with Branch ID: {branch_id}")

    # 4. Create new employee record
    admin_employee = Employee(
        name=admin_user.name,
        role='admin',
        salary=0.0,
        join_date=date.today(),
        user_id=admin_user.id,
        branch_id=branch_id,
        paid_leave_balance=12,
        sick_leave_balance=12,
        long_leave_balance=5,
        wellness_leave_balance=5
    )
    db.add(admin_employee)
    db.commit()
    print("Successfully created employee record for 'Zeebull Administrator'!")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
    db.rollback()
finally:
    db.close()
