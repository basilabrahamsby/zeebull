#!/usr/bin/env python3
"""Test delete employee operation and capture traceback of any 500 error."""

import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee
from app.curd.employee import delete_employee

db = SessionLocal()

try:
    # 1. Create a dummy user and employee to safely test deletion
    from app.models.user import Role
    admin_role = db.query(Role).first()
    
    from sqlalchemy import text
    branch_res = db.execute(text("SELECT id FROM branches LIMIT 1")).first()
    branch_id = branch_res[0] if branch_res else 1

    test_user = User(
        name="Test Dummy",
        email="dummy@test.com",
        hashed_password="dummy",
        role_id=admin_role.id,
        is_active=True
    )
    db.add(test_user)
    db.flush()

    test_employee = Employee(
        name="Test Dummy",
        role="Manager",
        salary=100.0,
        user_id=test_user.id,
        branch_id=branch_id
    )
    db.add(test_employee)
    db.commit()
    print(f"Created dummy employee with ID: {test_employee.id}")

    # 2. Try to delete the employee
    print(f"Attempting to delete employee ID: {test_employee.id}...")
    delete_employee(db, test_employee.id)
    print("Delete operation succeeded in test script!")

except Exception as e:
    print("\n!!! EXCEPTION CAUGHT !!!")
    print(f"Error Type: {type(e).__name__}")
    print(f"Error Message: {e}")
    import traceback
    traceback.print_exc()
    db.rollback()
finally:
    # Clean up if still exists
    try:
        dummy_emp = db.query(Employee).filter(Employee.name == "Test Dummy").first()
        if dummy_emp:
            db.delete(dummy_emp)
        dummy_user = db.query(User).filter(User.name == "Test Dummy").first()
        if dummy_user:
            db.delete(dummy_user)
        db.commit()
    except:
        pass
    db.close()
