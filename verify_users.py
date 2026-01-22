import sys
import os
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.user import User

db = SessionLocal()
users = db.query(User).filter(User.email.like('%orchid%')).all()

for u in users:
    print(f"Email: {u.email}")
    print(f"  Role ID: {u.role_id}")
    print(f"  Active: {u.is_active}")
    print(f"  Hash (first 30): {u.hashed_password[:30]}...")
    print()
