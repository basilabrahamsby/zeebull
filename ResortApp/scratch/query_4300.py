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
    
    print("=== ROOM 301 PRICE ===")
    cur.execute("SELECT id, number, price, status, room_type_id FROM rooms WHERE number = '301';")
    row = cur.fetchone()
    if row:
        print(f"Room ID: {row[0]}, Number: {row[1]}, Price: {row[2]}, Status: {row[3]}, Room Type ID: {row[4]}")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
