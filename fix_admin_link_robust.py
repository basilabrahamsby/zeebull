import requests
import json
import base64
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import os
import sys

# Try multiple connection strings if one fails
CONN_STRINGS = [
    "postgresql+psycopg2://postgres:qwerty123@localhost:5432/orchiddb",
    "postgresql://postgres:qwerty123@localhost:5432/orchiddb",
    "postgresql+psycopg2://postgres:qwerty123@127.0.0.1:5432/orchiddb",
    os.getenv("DATABASE_URL")
]

def get_db_session():
    for url in CONN_STRINGS:
        if not url: continue
        try:
            print(f"Trying DB connection: {url.split('@')[-1]}") # hide password
            engine = create_engine(url)
            SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
            db = SessionLocal()
            # Test connection
            db.execute(text("SELECT 1"))
            print("Connected successfully!")
            return db
        except Exception as e:
            print(f"Connection failed: {e}")
    return None

def fix_link():
    db = get_db_session()
    if not db:
        print("CRITICAL: Could not connect to database with any known credential.")
        return

    try:
        # 1. Get User
        print("Searching for admin user...")
        user = db.execute(text("SELECT id, email FROM users WHERE email = 'admin@orchid.com'")).fetchone()
        if not user:
            print("User admin@orchid.com NOT FOUND.")
            return
        
        user_id = user[0]
        print(f"Found User ID: {user_id}")

        # 2. Check Employee Link
        emp = db.execute(text(f"SELECT id, name FROM employees WHERE user_id = {user_id}")).fetchone()
        
        if emp:
            print(f"User is ALREADY linked to Employee ID {emp[0]} ({emp[1]}).")
            # If linked, why is token missing it? 
            # Maybe is_active is false? 
            # Or maybe verify_token.py is checking the old token? (No, it generates new one)
        else:
            print("User is NOT linked to any employee. Creating link...")
            
            # Create Employee
            query = text("""
                INSERT INTO employees (name, role, salary, join_date, phone, email, status, user_id, image_url)
                VALUES ('Admin Manager', 'Manager', 0, '2025-01-01', '0000000000', 'admin@orchid.com', 'Active', :uid, '')
                RETURNING id
            """)
            result = db.execute(query, {"uid": user_id}).fetchone()
            new_id = result[0]
            db.commit()
            print(f"SUCCESS: Created Employee ID {new_id} linked to User {user_id}")

    except Exception as e:
        print(f"Error during fix: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    fix_link()
