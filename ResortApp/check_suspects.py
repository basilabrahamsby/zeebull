
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    print("Checking specific suspect employees:")
    sql = text("""
        SELECT e.id, e.name, e.role, e.user_id, u.email
        FROM employees e
        JOIN users u ON e.user_id = u.id
        WHERE u.id IN (41, 42, 43, 61)
    """)
    result = conn.execute(sql).mappings().all()
    for row in result:
        print(f"Emp ID: {row['id']}, Name: {row['name']}, EmpRole: {row['role']}, UserID: {row['user_id']}, Email: {row['email']}")
