#!/usr/bin/env python3
import sys
sys.path.insert(0, '/var/www/inventory/ResortApp')

from app.database import SessionLocal
from app.models.user import User, Role
from app.utils.auth import get_password_hash
import json

db = SessionLocal()

try:
    # Get admin role
    admin_role = db.query(Role).filter(Role.name == "admin").first()
    
    # Create test user
    email = "test@orchid.com"
    password = "test123"
    
    # Delete if exists
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        db.delete(existing)
        db.commit()
    
    # Create new user
    hashed_pwd = get_password_hash(password)
    user = User(
        name="Test User",
        email=email,
        hashed_password=hashed_pwd,
        phone="9999999999",
        role_id=admin_role.id,
        is_active=True
    )
    db.add(user)
    db.commit()
    
    print("=" * 40)
    print("TEST USER CREATED:")
    print(f"Email:    {email}")
    print(f"Password: {password}")
    print("=" * 40)
    
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
finally:
    db.close()
