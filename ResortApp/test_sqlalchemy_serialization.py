#!/usr/bin/env python3
"""Test if returning a deleted SQLAlchemy object throws an ObjectDeletedError after commit."""

import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User, Role
from app.models.employee import Employee
from app.curd.employee import delete_employee
from fastapi.encoders import jsonable_encoder

db = SessionLocal()

try:
    print("=== TESTING SQLALCHEMY SERIALIZATION ERROR ===")
    
    # 1. Create a dummy user and employee
    admin_role = db.query(Role).first()
    from sqlalchemy import text
    branch_res = db.execute(text("SELECT id FROM branches LIMIT 1")).first()
    branch_id = branch_res[0] if branch_res else 1

    test_user = User(
        name="Serial Dummy",
        email="serial@test.com",
        hashed_password="dummy",
        role_id=admin_role.id,
        is_active=True
    )
    db.add(test_user)
    db.flush()

    test_employee = Employee(
        name="Serial Dummy",
        role="Manager",
        salary=100.0,
        user_id=test_user.id,
        branch_id=branch_id
    )
    db.add(test_employee)
    db.commit()
    print(f"Created test employee ID: {test_employee.id}")

    # 2. Run delete
    deleted = delete_employee(db, test_employee.id)
    print(f"Delete method returned employee: {deleted}")

    # 3. Simulate FastAPI response serialization (which triggers lazy load/attribute access)
    print("Simulating serialization of deleted object...")
    try:
        # Accessing any attribute like name or ID
        print(f"Deleted Employee Name: {deleted.name}")
        print("Access succeeded!")
    except Exception as ser_err:
        print("\n!!! SERIALIZATION EXCEPTION CAUGHT !!!")
        print(f"Error Type: {type(ser_err).__name__}")
        print(f"Error Message: {ser_err}")
        import traceback
        traceback.print_exc()

except Exception as e:
    print(f"Error: {e}")
    db.rollback()
finally:
    try:
        # Clean up
        dummy_emp = db.query(Employee).filter(Employee.name == "Serial Dummy").first()
        if dummy_emp:
            db.delete(dummy_emp)
        dummy_user = db.query(User).filter(User.name == "Serial Dummy").first()
        if dummy_user:
            db.delete(dummy_user)
        db.commit()
    except:
        pass
    db.close()
