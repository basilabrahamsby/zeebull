
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("DATABASE_URL not found in .env")
    exit(1)

engine = create_engine(DATABASE_URL)

def inspect_triggers():
    with engine.connect() as conn:
        print("--- Inspecting Triggers on 'users' and 'employees' tables ---")
        sql = text("""
            SELECT 
                event_object_table AS table_name, 
                trigger_name, 
                event_manipulation AS event, 
                action_statement AS action, 
                action_timing AS timing
            FROM information_schema.triggers 
            WHERE event_object_table IN ('users', 'employees')
            ORDER BY event_object_table, trigger_name;
        """)
        result = conn.execute(sql).mappings().all()
        
        if not result:
            print("No triggers found on 'users' or 'employees' tables.")
            return []
        
        for row in result:
            print(f"Table: {row['table_name']}")
            print(f"  Trigger: {row['trigger_name']}")
            print(f"  Timing: {row['timing']} {row['event']}")
            print(f"  Action: {row['action']}")
            print("-" * 40)
        return result

def check_guest_employees():
    with engine.connect() as conn:
        print("\n--- Checking for guests in 'employees' table ---")
        sql = text("""
            SELECT e.id, e.name, e.role, u.email 
            FROM employees e 
            JOIN users u ON e.user_id = u.id 
            WHERE u.email LIKE 'guest_%' OR u.email LIKE '%@temp.com'
        """)
        result = conn.execute(sql).mappings().all()
        if not result:
            print("No guest records found in 'employees' table.")
        else:
            print(f"Found {len(result)} guest records in 'employees' table:")
            for row in result:
                print(f"  ID: {row['id']}, Name: {row['name']}, Email: {row['email']}")

def remove_suspect_triggers(triggers):
    # Only remove if they look like they copy to employees
    with engine.connect() as conn:
        for t in triggers:
            name = t['trigger_name']
            table = t['table_name']
            if 'employee' in t['action'].lower() or 'employee' in name.lower():
                print(f"Dropping suspect trigger: {name} on {table}...")
                conn.execute(text(f"DROP TRIGGER IF EXISTS {name} ON {table};"))
                conn.commit()
                print("  ✓ Dropped.")

if __name__ == "__main__":
    triggers = inspect_triggers()
    check_guest_employees()
    
    if triggers:
        confirm = input("\nDo you want to attempt to remove suspect triggers? (yes/no): ").strip().lower()
        if confirm == 'yes':
            remove_suspect_triggers(triggers)
        else:
            print("Cleanup skipped.")
