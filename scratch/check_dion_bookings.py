import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from pathlib import Path

# Load env from ResortApp/.env
env_path = Path(__file__).parent.parent / "ResortApp" / ".env"
load_dotenv(dotenv_path=env_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("Error: DATABASE_URL not found in .env")
    sys.exit(1)

print(f"Connecting to: {DATABASE_URL}")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    # Find bookings with guest name like 'dion'
    bookings = conn.execute(text("""
        SELECT id, display_id, guest_name, check_in, check_out, room_rate, total_amount, room_type_id, status, created_at 
        FROM bookings 
        WHERE guest_name ILIKE '%dion%'
        ORDER BY id DESC
        LIMIT 5
    """)).fetchall()
    
    print("\n--- Recent bookings for Dion ---")
    if not bookings:
        print("No bookings found for Dion.")
    for b in bookings:
        print(f"ID: {b[0]}, DisplayID: {b[1]}, Guest: {b[2]}, CheckIn: {b[3]}, CheckOut: {b[4]}, RoomRate: {b[5]}, Total: {b[6]}, RoomTypeID: {b[7]}, Status: {b[8]}, CreatedAt: {b[9]}")
        
        # Query room type details
        rt = conn.execute(text(f"SELECT name FROM room_types WHERE id = {b[7]}")).fetchone()
        rt_name = rt[0] if rt else "Unknown"
        print(f"  Room Type: {rt_name}")
