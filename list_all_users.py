import sys
import os
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.user import User

db = SessionLocal()
users = db.query(User).all()

print(f"Total users: {len(users)}\n")

for u in users:
    print(f"Email: {u.email}")
    print(f"  Username: {getattr(u, 'username', 'N/A')}")
    print(f"  Role ID: {u.role_id}")
    print(f"  Active: {u.is_active}")
    print(f"  Hash (first 40): {u.hashed_password[:40]}...")
    print()
