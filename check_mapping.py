from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    result = conn.execute(text("SELECT u.email, e.name, e.image_url FROM users u JOIN employees e ON e.user_id = u.id"))
    for row in result:
        print(f"User: {row[0]}, EmpName: {row[1]}, Image: {row[2]}")
