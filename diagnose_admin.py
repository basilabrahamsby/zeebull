import requests
import json
import base64
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import os

# 1. DB Check
DATABASE_URL = "postgresql://postgres:qwerty123@localhost:5432/orchiddb"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def check_db():
    print("--- DB DIAGNOSIS ---")
    db = SessionLocal()
    try:
        # Check User
        user = db.execute(text("SELECT id, email, is_active FROM users WHERE email = 'admin@orchid.com'")).fetchone()
        print(f"User Found: {user}")
        if not user:
            print("CRITICAL: Admin user not found!")
            return

        user_id = user[0]
        
        # Check Link
        emp = db.execute(text(f"SELECT id, name, user_id FROM employees WHERE user_id = {user_id}")).fetchone()
        print(f"Linked Employee: {emp}")
        
        if not emp:
            print("STATUS: Admin User has NO linked Employee profile.")
            # FIX IT NOW
            print("Attempting to fix (CREATE LINK)...")
            # Check if an employee exists that looks like admin?
            # Or just create new
            try:
                # Create default manager employee
                query = text("""
                    INSERT INTO employees (name, role, salary, join_date, phone, email, status, user_id, image_url)
                    VALUES ('Admin Manager', 'Manager', 0, '2025-01-01', '0000000000', 'admin@orchid.com', 'Active', :uid, '')
                    RETURNING id
                """)
                new_id = db.execute(query, {"uid": user_id}).fetchone()[0]
                db.commit()
                print(f"FIXED: Created new Employee ID {new_id} linked to User {user_id}")
            except Exception as e:
                print(f"Fix Failed: {e}")
                db.rollback()
        else:
            print(f"STATUS: OK. Linked to Employee ID {emp[0]}")

    except Exception as e:
        print(f"DB Error: {e}")
    finally:
        db.close()

# 2. Token Check
def check_token():
    print("\n--- TOKEN CHECK ---")
    BASE_URL = "http://localhost:8011/api"
    try:
        resp = requests.post(f"{BASE_URL}/auth/login", json={
            "email": "admin@orchid.com",
            "password": "admin123" 
        })
        if resp.status_code == 200:
            token = resp.json()['access_token']
            # Decode
            parts = token.split(".")
            pad = '=' * (-len(parts[1]) % 4)
            payload = json.loads(base64.urlsafe_b64decode(parts[1] + pad))
            
            print(f"Token Payload: {json.dumps(payload)}")
            
            if 'employee_id' in payload:
                print("SUCCESS: Token contains employee_id.")
            else:
                print("FAILURE: Token MISSING employee_id.")
        else:
            print(f"Login Failed: {resp.status_code} {resp.text}")
    except Exception as e:
        print(f"Token Check Error: {e}")

if __name__ == "__main__":
    check_db()
    check_token()
