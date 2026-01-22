import sys
import os
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.user import User
from app.utils.auth import verify_password

db = SessionLocal()

# Check for housekeeping user
email = "housekeeping@orchid.com"
user = db.query(User).filter(User.email == email).first()

if user:
    print(f"✓ User found: {email}")
    print(f"  Role ID: {user.role_id}")
    print(f"  Active: {user.is_active}")
    print(f"  Hash: {user.hashed_password[:50]}...")
    
    # Test password
    password = "1234"
    is_valid = verify_password(password, user.hashed_password)
    print(f"  Password '1234' valid: {is_valid}")
else:
    print(f"✗ User NOT found: {email}")

print("\n--- All users with 'orchid' in email ---")
users = db.query(User).filter(User.email.like('%orchid%')).all()
for u in users:
    print(f"  - {u.email} (role_id: {u.role_id}, active: {u.is_active})")
