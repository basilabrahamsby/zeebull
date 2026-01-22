
import sys
import os
sys.path.append('/var/www/inventory/ResortApp')
from app.database import SessionLocal
from app.models.user import User

def list_users():
    db = SessionLocal()
    try:
        users = db.query(User).all()
        for u in users:
            print(f"ID: {u.id}, Email: {u.email}, Role: {u.role_id if hasattr(u, 'role_id') else 'N/A'}")
            # print(f"Hashed Pwd: {u.hashed_password}")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    list_users()
