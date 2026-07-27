#!/usr/bin/env python3
"""Diagnose delete employee error by running the actual database delete operations."""

import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee
from app.curd.employee import delete_employee

db = SessionLocal()

try:
    print("=== DIAGNOSING EMPLOYEE DELETE ERROR ===")
    
    # Find employee record for basil
    basil_emp = db.query(Employee).filter(Employee.name == 'basil').first()
    if not basil_emp:
        print("Employee 'basil' not found in employees table. Let's see if user exists...")
        basil_user = db.query(User).filter(User.name == 'basil').first()
        if basil_user:
            print(f"User 'basil' exists with ID={basil_user.id}, but no employee record found!")
            # Let's find any employee linked to this user_id
            linked_emp = db.query(Employee).filter(Employee.user_id == basil_user.id).first()
            if linked_emp:
                print(f"Found employee record linked to user_id: ID={linked_emp.id}, Name='{linked_emp.name}'")
                basil_emp = linked_emp
        else:
            print("User 'basil' not found either.")
            sys.exit(1)

    if basil_emp:
        print(f"Attempting to delete employee: ID={basil_emp.id}, Name='{basil_emp.name}', UserID={basil_emp.user_id}...")
        
        # Run delete_employee (mimicking app/api/employee.py delete_employee)
        # If it's linked to a user account, it will try to delete the user.
        if basil_emp.user:
            print(f"Employee has linked user: '{basil_emp.user.email}' (ID={basil_emp.user.id})")
            print("Executing: db.delete(employee.user)...")
            db.delete(basil_emp.user)
        else:
            print("Employee has no linked user. Executing: db.delete(employee)...")
            db.delete(basil_emp)
            
        print("Executing: db.commit()...")
        db.commit()
        print("Successfully deleted employee and linked user!")

except Exception as e:
    print("\n!!! DATABASE TRANSACTION EXCEPTION CAUGHT !!!")
    print(f"Error Type: {type(e).__name__}")
    print(f"Error Message: {e}")
    import traceback
    traceback.print_exc()
    db.rollback()
finally:
    db.close()
