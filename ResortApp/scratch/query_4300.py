import psycopg2
from dotenv import load_dotenv
import os
import json

load_dotenv()

db_url = os.getenv("DATABASE_URL")
if db_url.startswith("postgresql+psycopg2://"):
    db_url = db_url.replace("postgresql+psycopg2://", "postgresql://", 1)

try:
    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    
    print("=== DETAILS FOR CHECKOUT 36 ===")
    cur.execute("""
        SELECT room_total, food_total, service_total, package_total, tax_amount, 
               discount_amount, grand_total, advance_deposit, refund_amount, 
               late_checkout_fee, consumables_charges, inventory_charges, 
               asset_damage_charges, key_card_fee, tips_gratuity, bill_details
        FROM checkouts 
        WHERE id = 36;
    """)
    row = cur.fetchone()
    if row:
        fields = [
            "room_total", "food_total", "service_total", "package_total", "tax_amount", 
            "discount_amount", "grand_total", "advance_deposit", "refund_amount", 
            "late_checkout_fee", "consumables_charges", "inventory_charges", 
            "asset_damage_charges", "key_card_fee", "tips_gratuity"
        ]
        for f, val in zip(fields, row[:-1]):
            print(f"{f}: {val}")
        print("\n=== bill_details ===")
        print(json.dumps(row[-1], indent=2))
        
    print("\n=== DETAILS FOR BOOKING 73 ===")
    cur.execute("""
        SELECT id, display_id, guest_name, total_amount, advance_deposit, status, check_in, check_out, num_rooms, room_rate
        FROM bookings 
        WHERE id = 73;
    """)
    row = cur.fetchone()
    if row:
        fields = ["id", "display_id", "guest_name", "total_amount", "advance_deposit", "status", "check_in", "check_out", "num_rooms", "room_rate"]
        for f, val in zip(fields, row):
            print(f"{f}: {val}")

    print("\n=== PAYMENTS FOR BOOKING 73 ===")
    cur.execute("SELECT id, amount, payment_method, status, transaction_id, created_at FROM payments WHERE booking_id = 73;")
    for row in cur.fetchall():
        print(row)

    print("\n=== CHECKOUT PAYMENTS FOR CHECKOUT 36 ===")
    cur.execute("SELECT id, amount, payment_method, transaction_id, created_at FROM checkout_payments WHERE checkout_id = 36;")
    for row in cur.fetchall():
        print(row)
        
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
