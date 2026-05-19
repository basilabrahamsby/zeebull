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
    
    print("=== CHECKOUTS ===")
    cur.execute("SELECT id, booking_id, sub_total, cgst, sgst, grand_total, refund_amount, created_at FROM checkouts ORDER BY id DESC LIMIT 20;")
    for row in cur.fetchall():
        print(row)
        
    print("\n=== BOOKINGS ===")
    cur.execute("SELECT id, guest_id, total_amount, paid_amount, status, check_in, check_out FROM bookings ORDER BY id DESC LIMIT 20;")
    for row in cur.fetchall():
        print(row)

    print("\n=== FOOD ORDERS ===")
    cur.execute("SELECT id, room_id, table_id, sub_total, cgst, sgst, grand_total, status FROM food_orders ORDER BY id DESC LIMIT 20;")
    for row in cur.fetchall():
        print(row)
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
