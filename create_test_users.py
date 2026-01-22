import sys
import os
sys.path.append(os.getcwd())
from app.utils.auth import get_password_hash 
from app.database import SessionLocal
from app.models.user import User, Role

def create_users():
    db = SessionLocal()
    
    # 1. Get Roles - check both lowercase and capitalized
    try:
        all_roles = db.query(Role).all()
        print(f"DEBUG: All roles in DB:")
        for r in all_roles:
            print(f"  - ID:{r.id}, Name:'{r.name}'")
        
        roles_map = {}
        for r in all_roles:
            roles_map[r.name.lower()] = r.id
            roles_map[r.name] = r.id  # Also add the exact name
        
        print(f"\nDEBUG: Roles map: {roles_map}")
    except Exception as e:
        print(f"Error fetching roles: {e}")
        return

    # 2. Define Users
    users_data = [
        {'email': 'manager@orchid.com', 'role': 'manager', 'name': 'Manager Test', 'username': 'manager'},
        {'email': 'housekeeping@orchid.com', 'role': 'housekeeping', 'name': 'Housekeeping Staff', 'username': 'housekeeping'},
        {'email': 'kitchen@orchid.com', 'role': 'kitchen', 'name': 'Chef Test', 'username': 'chef'},
        {'email': 'waiter@orchid.com', 'role': 'waiter', 'name': 'Waiter Test', 'username': 'waiter'}
    ]

    # Generate hash using the EXACT logic server uses
    password = "1234"
    hashed_pwd = get_password_hash(password)
    print(f"\nDEBUG: Generated hash for '1234': {hashed_pwd[:30]}...")

    for u in users_data:
        role_name = u['role']
        role_id = roles_map.get(role_name.lower())
        
        # Try capitalized version
        if not role_id:
            role_id = roles_map.get(role_name.capitalize())
        
        # Try exact match
        if not role_id:
            role_id = roles_map.get(role_name)
            
        if not role_id:
            print(f"WARNING: Role '{role_name}' not found for {u['email']}. Skipped.")
            continue

        print(f"\nProcessing {u['email']} with role_id={role_id}...")
        
        # Check if user exists
        try:
            user = db.query(User).filter(User.email == u['email']).first()
            if not user:
                print(f"  Creating new user...")
                user = User(
                    email=u['email'],
                    username=u['username'],
                    hashed_password=hashed_pwd,
                    role_id=role_id,
                    first_name=u['name'],
                    is_active=True
                )
                db.add(user)
                print(f"  ✓ Added to session")
            else:
                print(f"  Updating existing user (ID: {user.id})...")
                user.hashed_password = hashed_pwd
                user.role_id = role_id
                user.first_name = u['name']
                user.is_active = True
                if not hasattr(user, 'username') or not user.username:
                    user.username = u['username']
                print(f"  ✓ Updated")
        except Exception as e:
            print(f"  ERROR processing user {u['email']}: {e}")
            import traceback
            traceback.print_exc()
    
    try:
        db.commit()
        print("\n✓✓✓ SUCCESS: Users created/updated with password '1234' ✓✓✓")
    except Exception as e:
        db.rollback()
        print(f"\n✗✗✗ ERROR committing to database: {e} ✗✗✗")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    create_users()
