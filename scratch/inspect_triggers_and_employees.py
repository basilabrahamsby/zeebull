import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load production env
load_dotenv('server_env_52.env')
db_url = os.getenv("DATABASE_URL")

if not db_url:
    print("Could not find DATABASE_URL in server_env_52.env")
    exit(1)

print(f"Connecting to database...")
engine = create_engine(db_url)

with engine.connect() as conn:
    print("\n--- DB Triggers on users/employees ---")
    triggers_query = text("""
        SELECT trigger_name, event_manipulation, event_object_table, action_statement 
        FROM information_schema.triggers 
        WHERE event_object_table IN ('users', 'employees')
    """)
    triggers = conn.execute(triggers_query).mappings().all()
    for t in triggers:
        print(f"Trigger: {t['trigger_name']} ON {t['event_object_table']} ({t['event_manipulation']}) -> {t['action_statement']}")
        
    print("\n--- Guests in Employees Table ---")
    overlap_query = text("""
        SELECT e.id as emp_id, e.name as emp_name, e.role, u.id as user_id, u.email, u.name as user_name
        FROM employees e 
        JOIN users u ON e.user_id = u.id 
        WHERE e.role = 'PURCHASE MANAGER' OR u.email LIKE 'guest_%'
    """)
    overlaps = conn.execute(overlap_query).mappings().all()
    print(f"Total overlapping guest records: {len(overlaps)}")
    for o in overlaps:
        print(f" - Emp ID: {o['emp_id']}, Name: {o['emp_name']}, Role: {o['role']}, User ID: {o['user_id']}, Email: {o['email']}")
        
    print("\n--- Roles check ---")
    roles = conn.execute(text("SELECT id, name FROM roles")).mappings().all()
    for r in roles:
        print(f"Role ID: {r['id']}, Name: {r['name']}")
