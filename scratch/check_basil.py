import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv("c:\\releasing\\New Orchid\\ResortApp\\.env")
db_url = os.getenv("DATABASE_URL")
engine = create_engine(db_url)

with engine.connect() as conn:
    print("--- Bookings created in last 30 minutes ---")
    query = """
        SELECT id, display_id, guest_name, check_in, check_out, total_amount, advance_deposit, status, room_type_id, num_rooms, created_at
        FROM bookings 
        WHERE created_at >= NOW() - INTERVAL '30 minutes'
        ORDER BY id DESC
    """
    res = conn.execute(text(query)).fetchall()
    for r in res:
        print(f"ID: {r.id} | Display: {r.display_id} | Guest: {r.guest_name} | Amount: {r.total_amount} | Rooms: {r.num_rooms} | Created At: {r.created_at} | RoomType: {r.room_type_id}")
