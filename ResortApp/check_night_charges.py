import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, booking_id, room_charge, gst_amount, rate_used FROM night_charges WHERE booking_id=150"))
    rows = res.fetchall()
    print("Night Charges:", [dict(r._mapping) for r in rows])
