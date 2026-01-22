
import sys
import os
sys.path.append('/var/www/inventory/ResortApp')
from app.database import SessionLocal
from app.models.user import User, Role
from app.utils.auth import get_password_hash

def ensure_admin():
    db = SessionLocal()
    try:
        email = "admin"
        password = "admin123"
        hashed = get_password_hash(password)
        
        # Ensure role exists
        admin_role = db.query(Role).filter(Role.name == "admin").first()
        if not admin_role:
            print("Creating admin role...")
            admin_role = Role(name="admin", description="Administrator")
            db.add(admin_role)
            db.commit()
            db.refresh(admin_role)
            
        user = db.query(User).filter(User.email == email).first()
        if not user:
            print(f"Creating user {email}...")
            user = User(
                email=email,
                hashed_password=hashed,
                is_active=True,
                role_id=admin_role.id
            )
            db.add(user)
        else:
            print(f"Updating user {email}...")
            user.hashed_password = hashed
            user.is_active = True
            user.role_id = admin_role.id
            
        db.commit()
        print("Admin user ready.")
        
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    ensure_admin()
