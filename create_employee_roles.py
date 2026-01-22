import sys
import os
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.user import Role

db = SessionLocal()

# Define the roles we need
required_roles = [
    {"name": "Housekeeping", "permissions": "housekeeping_access"},
    {"name": "Kitchen", "permissions": "kitchen_access"},
    {"name": "Waiter", "permissions": "waiter_access"},
]

print("=== CREATING MISSING ROLES ===")
for role_data in required_roles:
    existing = db.query(Role).filter(Role.name == role_data["name"]).first()
    if existing:
        print(f"✓ Role '{role_data['name']}' already exists (ID: {existing.id})")
    else:
        new_role = Role(
            name=role_data["name"],
            permissions=role_data["permissions"]
        )
        db.add(new_role)
        print(f"+ Creating role: {role_data['name']}")

db.commit()
print("\n=== ALL ROLES AFTER UPDATE ===")
roles = db.query(Role).all()
for r in roles:
    print(f"ID: {r.id} - Name: '{r.name}'")
