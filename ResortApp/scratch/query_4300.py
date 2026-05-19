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
    
    print("=== ROOM 301 TYPE AND BASE PRICE ===")
    cur.execute("""
        SELECT r.id, r.number, rt.name, rt.base_price 
        FROM rooms r
        JOIN room_types rt ON r.room_type_id = rt.id
        WHERE r.number = '301';
    """)
    row = cur.fetchone()
    if row:
        print(f"Room ID: {row[0]}, Number: {row[1]}, Type Name: {row[2]}, Base Price: {row[3]}")
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
