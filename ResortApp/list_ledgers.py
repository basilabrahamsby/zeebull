import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

db_url = os.getenv("DATABASE_URL")
if db_url.startswith("postgresql+psycopg2://"):
    db_url = db_url.replace("postgresql+psycopg2://", "postgresql://", 1)

try:
    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    
    print("Ledger Names:")
    cur.execute("SELECT id, name, module, branch_id FROM account_ledgers WHERE is_active = True;")
    rows = cur.fetchall()
    for row in rows:
        print(f"ID: {row[0]}, Name: '{row[1]}', Module: {row[2]}, Branch: {row[3]}")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
