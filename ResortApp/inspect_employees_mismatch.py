#!/usr/bin/env python3
"""Inspect users and employees tables in the database."""

import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee
from sqlalchemy import text

db = SessionLocal()

try:
    print("=== USERS IN DATABASE ===")
    users = db.query(User).all()
    for u in users:
        print(f"ID={u.id} | Name='{u.name}' | Email='{u.email}' | RoleID={u.role_id} | RoleName='{u.role.name if u.role else 'None'}'")
    
    print("\n=== EMPLOYEES IN DATABASE ===")
    employees = db.query(Employee).all()
    for e in employees:
        print(f"ID={e.id} | Name='{e.name}' | UserID={e.user_id} | Role='{e.role}' | BranchID={e.branch_id}")

except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
