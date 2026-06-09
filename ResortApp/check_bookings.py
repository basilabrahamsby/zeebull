
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    print("Checking bookings for suspect users:")
    sql = text("""
        SELECT b.id, b.guest_name, b.user_id, u.email, r.name as role_name
        FROM bookings b
        JOIN users u ON b.user_id = u.id
        JOIN roles r ON u.role_id = r.id
        WHERE u.id IN (41, 42, 43, 61)
    """)
    result = conn.execute(sql).mappings().all()
    for row in result:
        print(f"Booking ID: {row['id']}, Guest: {row['guest_name']}, UserID: {row['user_id']}, Email: {row['email']}, Role: {row['role_name']}")
