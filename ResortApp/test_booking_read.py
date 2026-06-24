import asyncio
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.booking import Booking

def read_db():
    db = SessionLocal()
    try:
        booking = db.query(Booking).filter(Booking.id == 152).first()
        print(f"Booking ID: {booking.id}")
        print(f"Room Rate: {booking.room_rate}")
        print(f"Total Amount: {booking.total_amount}")
        print(f"Balance: {booking.balance}")
        print(f"Paid Amount: {booking.paid_amount}")
    finally:
        db.close()

if __name__ == "__main__":
    read_db()
