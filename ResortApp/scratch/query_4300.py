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
    
    print("=== CHECKOUTS WITH GRAND TOTAL = 4300 ===")
    cur.execute("""
        SELECT id, booking_id, package_booking_id, room_total, food_total, service_total, 
               package_total, tax_amount, discount_amount, grand_total, advance_deposit, 
               refund_amount, room_number, guest_name, invoice_number, created_at, bill_details
        FROM checkouts 
        WHERE grand_total = 4300 OR room_total = 4300 OR food_total = 4300 OR package_total = 4300;
    """)
    rows = cur.fetchall()
    if not rows:
        print("No matching checkouts found.")
    else:
        for row in rows:
            print(f"ID: {row[0]}, Booking ID: {row[1]}, Pkg Booking ID: {row[2]}")
            print(f"  Room Total: {row[3]}, Food Total: {row[4]}, Service Total: {row[5]}, Package Total: {row[6]}")
            print(f"  Tax: {row[7]}, Discount: {row[8]}, Grand Total: {row[9]}, Advance Deposit: {row[10]}, Refund: {row[11]}")
            print(f"  Room No: {row[12]}, Guest: {row[13]}, Invoice: {row[14]}, Created At: {row[15]}")
            print(f"  Bill Details: {row[16]}")
            print("-" * 50)
        
    print("\n=== BOOKINGS WITH TOTAL = 4300 ===")
    cur.execute("""
        SELECT id, guest_id, total_amount, paid_amount, status, check_in, check_out, advance_amount
        FROM bookings 
        WHERE total_amount = 4300 OR paid_amount = 4300;
    """)
    rows = cur.fetchall()
    if not rows:
        print("No matching bookings found.")
    else:
        for row in rows:
            print(row)

    print("\n=== FOOD ORDERS WITH GRAND TOTAL = 4300 ===")
    cur.execute("""
        SELECT id, room_id, table_id, sub_total, cgst, sgst, grand_total, status 
        FROM food_orders 
        WHERE grand_total = 4300 OR sub_total = 4300;
    """)
    rows = cur.fetchall()
    if not rows:
        print("No matching food orders found.")
    else:
        for row in rows:
            print(row)
            
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
