
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("DATABASE_URL not found!")
    exit(1)

engine = create_engine(DATABASE_URL)

def cleanup():
    with engine.connect() as conn:
        # 1. Drop suspect triggers
        print("Finding triggers on 'users' table...")
        sql = text("SELECT trigger_name FROM information_schema.triggers WHERE event_object_table = 'users'")
        triggers = conn.execute(sql).mappings().all()
        for t in triggers:
            name = t['trigger_name']
            print(f"Dropping trigger: {name} on users")
            conn.execute(text(f"DROP TRIGGER IF EXISTS {name} ON users;"))
            conn.commit()
            print(f"✓ Dropped {name}")

        print("\nFinding triggers on 'employees' table...")
        sql = text("SELECT trigger_name FROM information_schema.triggers WHERE event_object_table = 'employees'")
        triggers = conn.execute(sql).mappings().all()
        for t in triggers:
            name = t['trigger_name']
            print(f"Dropping trigger: {name} on employees")
            conn.execute(text(f"DROP TRIGGER IF EXISTS {name} ON employees;"))
            conn.commit()
            print(f"✓ Dropped {name}")

        # 2. Delete guests from employees table
        print("\nCleaning up guest records from 'employees' table...")
        
        # Method A: Based on user role name
        sql = text("""
            DELETE FROM employees 
            WHERE user_id IN (
                SELECT u.id 
                FROM users u 
                JOIN roles r ON u.role_id = r.id 
                WHERE LOWER(r.name) = 'guest'
            )
        """)
        res = conn.execute(sql)
        conn.commit()
        print(f"✓ Deleted {res.rowcount} records from employees based on 'guest' role.")

        # Method B: Based on email patterns (backup check)
        sql = text("""
            DELETE FROM employees 
            WHERE user_id IN (
                SELECT id 
                FROM users 
                WHERE email LIKE 'guest_%' OR email LIKE '%@temp.com'
            )
        """)
        res = conn.execute(sql)
        conn.commit()
        print(f"✓ Deleted {res.rowcount} records from employees based on email patterns.")

if __name__ == "__main__":
    cleanup()
