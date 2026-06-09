
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

def inspect():
    with engine.connect() as conn:
        print("--- Comprehensive Trigger Inspection ---")
        
        sql = text("""
            SELECT 
                event_object_table AS table_name,
                trigger_name, 
                event_manipulation AS event, 
                action_statement AS action, 
                action_timing AS timing
            FROM information_schema.triggers 
            ORDER BY table_name, trigger_name
        """)
        results = conn.execute(sql).mappings().all()
        if not results:
            print("No triggers found in the database.")
        for r in results:
            print(f"Table: {r['table_name']}")
            print(f"  Name: {r['trigger_name']}, Event: {r['timing']} {r['event']}")
            print(f"  Action: {r['action']}")
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
