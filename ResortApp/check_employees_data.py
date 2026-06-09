
from sqlalchemy import create_session
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    # Try to find .env file
    env_path = os.path.join(os.path.dirname(__file__), ".env")
    if os.path.exists(env_path):
        load_dotenv(env_path)
        DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    print("DATABASE_URL not found")
    exit(1)

engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    print("Checking for guests in employees table...")
    sql = text("""
        SELECT e.id as emp_id, e.name as emp_name, e.role as emp_role, u.id as user_id, u.email as user_email, u.name as user_name
        FROM employees e
        JOIN users u ON e.user_id = u.id
        WHERE u.email LIKE 'guest_%' OR u.email LIKE '%@temp.com'
    """)
    result = conn.execute(sql).mappings().all()
    
    if not result:
        print("No guests found in employees table.")
    else:
        print(f"Found {len(result)} guests in employees table:")
        for row in result:
            print(f"Emp ID: {row['emp_id']}, Name: {row['emp_name']}, Role: {row['emp_role']}, User ID: {row['user_id']}, Email: {row['user_email']}")

    print("\nChecking for roles distribution in employees table:")
    sql_roles = text("""
        SELECT role, COUNT(*) as count
        FROM employees
        GROUP BY role
    """)
    roles_result = conn.execute(sql_roles).mappings().all()
    for row in roles_result:
        print(f"Role: {row['role']}, Count: {row['count']}")

    print("\nChecking for recent employee additions:")
    sql_recent = text("""
        SELECT id, name, role, user_id
        FROM employees
        ORDER BY id DESC
        LIMIT 10
    """)
    recent_result = conn.execute(sql_recent).mappings().all()
    for row in recent_result:
        print(f"ID: {row['id']}, Name: {row['name']}, Role: {row['role']}, User ID: {row['user_id']}")
