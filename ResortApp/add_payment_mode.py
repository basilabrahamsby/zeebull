import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

db_url = os.getenv("DATABASE_URL")
if db_url.startswith("postgresql+psycopg2://"):
    db_url = db_url.replace("postgresql+psycopg2://", "postgresql://", 1)

try:
    conn = psycopg2.connect(db_url)
    conn.autocommit = True
    cur = conn.cursor()
    
    print("Checking if 'payment_mode' column exists in 'expenses'...")
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='expenses' AND column_name='payment_mode';")
    exists = cur.fetchone()
    
    if not exists:
        print("Adding 'payment_mode' column to 'expenses' table...")
        cur.execute("ALTER TABLE expenses ADD COLUMN payment_mode VARCHAR NOT NULL DEFAULT 'Cash';")
        print("Column added successfully.")
    else:
        print("Column 'payment_mode' already exists.")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
