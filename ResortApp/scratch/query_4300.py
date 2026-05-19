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
    
    print("=== LATEST 10 CHECKOUTS ===")
    cur.execute("""
        SELECT id, booking_id, package_booking_id, room_total, food_total, service_total, 
               package_total, tax_amount, discount_amount, grand_total, advance_deposit, 
               refund_amount, room_number, guest_name, invoice_number, created_at
        FROM checkouts 
        ORDER BY id DESC LIMIT 10;
    """)
    for row in cur.fetchall():
        print(row)
        
    print("\n=== LATEST 10 BOOKINGS ===")
    cur.execute("""
        SELECT id, display_id, guest_name, total_amount, advance_deposit, status, check_in, check_out 
        FROM bookings 
        ORDER BY id DESC LIMIT 10;
    """)
    for row in cur.fetchall():
        print(row)

    print("\n=== LATEST 10 PACKAGE BOOKINGS ===")
    cur.execute("""
        SELECT id, display_id, guest_name, total_amount, advance_deposit, status, check_in, check_out 
        FROM package_bookings 
        ORDER BY id DESC LIMIT 10;
    """)
    for row in cur.fetchall():
        print(row)
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
