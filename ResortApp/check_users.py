
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    print("Listing all users and their roles:")
    sql = text("""
        SELECT u.id, u.name, u.email, r.name as role_name
        FROM users u
        LEFT JOIN roles r ON u.role_id = r.id
        ORDER BY u.id DESC
        LIMIT 20
    """)
    result = conn.execute(sql).mappings().all()
    for row in result:
        print(f"ID: {row['id']}, Name: {row['name']}, Email: {row['email']}, Role: {row['role_name']}")
