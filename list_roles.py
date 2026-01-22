import sys
import os
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.user import Role

db = SessionLocal()

print("=== ALL ROLES ===")
roles = db.query(Role).all()
for r in roles:
    print(f"ID: {r.id} - Name: '{r.name}'")
