import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.booking import Booking, BookingRoom
from app.models.room import Room

db = SessionLocal()
try:
    print("--- ROOM 302 STATUS ---")
    room = db.query(Room).filter(Room.number == "302").first()
    if room:
        print(f"Room ID: {room.id}, Number: {room.number}, Status: {room.status}")
        # Find bookings
        links = db.query(BookingRoom).filter(BookingRoom.room_id == room.id).all()
        print(f"Found {len(links)} booking connections.")
        for l in links:
            b = l.booking
            print(f"  Booking ID: {b.id}, Guest: {b.guest_name}, Status: {b.status}, Checked In At: {b.checked_in_at}, Checked Out At: {b.checked_out_at}")
    else:
        print("Room 302 not found")
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
