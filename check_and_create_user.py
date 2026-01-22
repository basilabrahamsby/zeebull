import sys
import os
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.user import User
from app.utils.auth import verify_password, get_password_hash

db = SessionLocal()

# First, let's see what users exist
print("=== ALL USERS ===")
all_users = db.query(User).all()
print(f"Total: {len(all_users)}")
for u in all_users:
    print(f"{u.id}. {u.email} - Role:{u.role_id} - Active:{u.is_active}")

print("\n=== CHECKING HOUSEKEEPING USER ===")
email = "housekeeping@orchid.com"
user = db.query(User).filter(User.email == email).first()

if user:
    print(f"FOUND: {email}")
    print(f"  ID: {user.id}")
    print(f"  Role ID: {user.role_id}")
    print(f"  Active: {user.is_active}")
    print(f"  Hash: {user.hashed_password}")
    
    # Test password
    password = "1234"
    try:
        is_valid = verify_password(password, user.hashed_password)
        print(f"  Password '{password}' verification result: {is_valid}")
    except Exception as e:
        print(f"  Password verification ERROR: {e}")
else:
    print(f"NOT FOUND: {email}")
    print("\nCreating user now...")
    
    # Create the user
    from app.models.user import Role
    role = db.query(Role).filter(Role.name == "Housekeeping").first()
    if not role:
        print("ERROR: Housekeeping role not found!")
        print("Available roles:")
        for r in db.query(Role).all():
            print(f"  - {r.name} (ID: {r.id})")
    else:
        new_user = User(
            email=email,
            username="housekeeping",
            hashed_password=get_password_hash("1234"),
            role_id=role.id,
            first_name="Housekeeping Staff",
            is_active=True
        )
        db.add(new_user)
        db.commit()
        print(f"✓ Created user: {email}")
