import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

db_url = os.getenv("DATABASE_URL")
# Handle postgresql+psycopg2:// -> postgresql://
if db_url.startswith("postgresql+psycopg2://"):
    db_url = db_url.replace("postgresql+psycopg2://", "postgresql://", 1)

try:
    conn = psycopg2.connect(db_url)
    conn.autocommit = True
    cur = conn.cursor()
    
    print("Checking if 'refund_amount' column exists in 'checkouts'...")
    cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='checkouts' AND column_name='refund_amount';")
    exists = cur.fetchone()
    
    if not exists:
        print("Adding 'refund_amount' column to 'checkouts' table...")
        cur.execute("ALTER TABLE checkouts ADD COLUMN refund_amount FLOAT DEFAULT 0.0;")
        print("Column added successfully.")
    else:
        print("Column 'refund_amount' already exists.")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
