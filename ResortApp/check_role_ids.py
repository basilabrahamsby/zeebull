
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    print("Listing roles and users with their role IDs:")
    sql = text("""
        SELECT u.id, u.name, u.email, u.role_id, r.name as role_name
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        WHERE u.id IN (41, 42, 43, 61)
    """)
    result = conn.execute(sql).mappings().all()
    for row in result:
        print(f"User ID: {row['id']}, Name: {row['name']}, Role ID: {row['role_id']}, Role Name: {row['role_name']}")

    print("\nAll available roles and their IDs:")
    sql_roles = text("SELECT id, name FROM roles")
    roles_result = conn.execute(sql_roles).mappings().all()
    for row in roles_result:
        print(f"Role ID: {row['id']}, Role Name: {row['name']}")
