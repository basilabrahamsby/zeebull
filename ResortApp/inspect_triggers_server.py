
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

def inspect():
    with engine.connect() as conn:
        print("--- Detailed Trigger Inspection ---")
        
        # 1. Triggers on users table
        print("\nTriggers on 'users':")
        sql = text("""
            SELECT 
                trigger_name, 
                event_manipulation, 
                action_statement, 
                action_timing
            FROM information_schema.triggers 
            WHERE event_object_table = 'users'
        """)
        results = conn.execute(sql).mappings().all()
        for r in results:
            print(f"Name: {r['trigger_name']}, Event: {r['action_timing']} {r['event_manipulation']}")
            print(f"Action: {r['action_statement']}")
            print("-" * 20)

        # 2. Triggers on employees table
        print("\nTriggers on 'employees':")
        sql = text("""
            SELECT 
                trigger_name, 
                event_manipulation, 
                action_statement, 
                action_timing
            FROM information_schema.triggers 
            WHERE event_object_table = 'employees'
        """)
        results = conn.execute(sql).mappings().all()
        for r in results:
            print(f"Name: {r['trigger_name']}, Event: {r['action_timing']} {r['event_manipulation']}")
            print(f"Action: {r['action_statement']}")
            print("-" * 20)

        # 3. Check for any record in employees where role is 'PURCHASE MANAGER' but it's actually a guest
        print("\nChecking 'employees' table for suspect roles...")
        sql = text("""
            SELECT e.id, e.name, e.role, u.email 
            FROM employees e
            JOIN users u ON e.user_id = u.id
            WHERE e.role = 'PURCHASE MANAGER'
        """)
        results = conn.execute(sql).mappings().all()
        for r in results:
            print(f"ID: {r['id']}, Name: {r['name']}, Role: {r['role']}, Email: {r['email']}")

if __name__ == "__main__":
    inspect()
