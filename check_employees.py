from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    result = conn.execute(text("SELECT id, name, image_url FROM employees"))
    for row in result:
        print(f"ID: {row[0]}, Name: {row[1]}, Image: {row[2]}")
