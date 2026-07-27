import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv("c:\\releasing\\New Orchid\\ResortApp\\.env")
db_url = os.getenv("DATABASE_URL")

print(f"Connecting to database: {db_url}")
engine = create_engine(db_url)

with engine.connect() as conn:
    # Get booking 88 details
    res = conn.execute(text("SELECT id, display_id, guest_name, status, check_in, check_out FROM bookings WHERE id = 88 OR display_id = 'BK-1-000088'"))
    bookings = res.fetchall()
    print("\n--- Bookings ---")
    for b in bookings:
        print(f"ID: {b[0]} | Display: {b[1]} | Guest: {b[2]} | Status: {b[3]} | CheckIn: {b[4]} | CheckOut: {b[5]}")
        booking_id = b[0]

    # Get booking rooms
    res = conn.execute(text("SELECT room_id, (SELECT number FROM rooms WHERE id = room_id) as room_num FROM booking_rooms WHERE booking_id = :bid"), {"bid": booking_id})
    booking_rooms = res.fetchall()
    print("\n--- Booking Rooms ---")
    for br in booking_rooms:
        # Get room status
        room_res = conn.execute(text("SELECT id, number, status FROM rooms WHERE id = :rid"), {"rid": br[0]})
        room = room_res.fetchone()
        print(f"Room ID: {br[0]} | Room Num: {br[1]} | DB Room Status: {room[2] if room else 'N/A'}")

    # Get checkout request status
    res = conn.execute(text("SELECT id, room_number, status, inventory_checked, completed_at FROM checkout_requests WHERE booking_id = :bid"), {"bid": booking_id})
    reqs = res.fetchall()
    print("\n--- Checkout Requests ---")
    for r in reqs:
        print(f"ID: {r[0]} | Room: {r[1]} | Status: {r[2]} | Inv Checked: {r[3]} | CompletedAt: {r[4]}")

    # Get checkout records
    res = conn.execute(text("SELECT id, room_number, checkout_date, grand_total FROM checkouts WHERE booking_id = :bid"), {"bid": booking_id})
    checkouts = res.fetchall()
    print("\n--- Checkout Records ---")
    for c in checkouts:
        print(f"ID: {c[0]} | Room: {c[1]} | Date: {c[2]} | Grand Total: {c[3]}")
