from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    conn.execute(text("UPDATE employees SET image_url = 'uploads/Untitled.jpg' WHERE image_url = 'uploads/employees/Untitled.jpg'"))
    conn.commit()
    print("Updated image paths")
