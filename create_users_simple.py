import sys
import os
sys.path.append(os.getcwd())
from app.utils.auth import get_password_hash 
from app.database import SessionLocal
from app.models.user import User, Role

def create_users():
    db = SessionLocal()
    
    # Get roles
    all_roles = db.query(Role).all()
    print("Available roles:")
    for r in all_roles:
        print(f"  - ID:{r.id}, Name:'{r.name}'")
    
    roles_map = {r.name: r.id for r in all_roles}
    
    # Define users with exact role names as they appear in DB
    users_data = [
        {'email': 'manager@orchid.com', 'role_name': 'manager'},
        {'email': 'housekeeping@orchid.com', 'role_name': 'Housekeeping'},
        {'email': 'kitchen@orchid.com', 'role_name': 'Kitchen'},
        {'email': 'waiter@orchid.com', 'role_name': 'Waiter'}
    ]

    password = "1234"
    hashed_pwd = get_password_hash(password)

    for u in users_data:
        role_id = roles_map.get(u['role_name'])
        
        if not role_id:
            print(f"✗ Role '{u['role_name']}' not found for {u['email']}")
            continue

        print(f"\nProcessing {u['email']} (role_id={role_id})...")
        
        user = db.query(User).filter(User.email == u['email']).first()
        if not user:
            print(f"  Creating new user...")
            # Only use fields that definitely exist
            user = User(
                email=u['email'],
                hashed_password=hashed_pwd,
                role_id=role_id,
                is_active=True
            )
            db.add(user)
        else:
            print(f"  Updating existing user...")
            user.hashed_password = hashed_pwd
            user.role_id = role_id
            user.is_active = True
    
    db.commit()
    print("\n✓ SUCCESS: Users created/updated")

if __name__ == "__main__":
    create_users()
