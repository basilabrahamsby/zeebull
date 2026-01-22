import sys
import os
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.user import User
from app.utils.auth import verify_password

db = SessionLocal()

email = "housekeeping@orchid.com"
user = db.query(User).filter(User.email == email).first()

if user:
    print(f"USER EXISTS: {email}")
    print(f"Role ID: {user.role_id}")
    print(f"Active: {user.is_active}")
    
    # Test password
    is_valid = verify_password("1234", user.hashed_password)
    print(f"Password valid: {is_valid}")
    
    if is_valid:
        print("\n✓✓✓ LOGIN SHOULD WORK ✓✓✓")
    else:
        print("\n✗✗✗ PASSWORD MISMATCH ✗✗✗")
else:
    print(f"USER NOT FOUND: {email}")
