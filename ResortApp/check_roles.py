
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    print("Listing all roles:")
    sql = text("""
        SELECT id, name, branch_id
        FROM roles
    """)
    result = conn.execute(sql).mappings().all()
    for row in result:
        print(f"ID: {row['id']}, Name: {row['name']}, Branch ID: {row['branch_id']}")
