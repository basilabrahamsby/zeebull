import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, guest_name, total_amount, advance_deposit, num_rooms, room_rate, status FROM bookings WHERE guest_name LIKE '%deljo%' ORDER BY id DESC LIMIT 5"))
    rows = res.fetchall()
    print("Recent Bookings:", [dict(r._mapping) for r in rows])
