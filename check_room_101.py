from app.db.session import SessionLocal
from app.models.booking import Booking, BookingRoom
from sqlalchemy import or_, and_
import datetime

db = SessionLocal()
room_id = 1
start_date = datetime.date(2026, 1, 9)
end_date = datetime.date(2026, 1, 10)

print(f"Checking conflicts for Room {room_id} between {start_date} and {end_date}...")

conflicts = db.query(Booking).join(BookingRoom).filter(
    BookingRoom.room_id == room_id,
    or_(Booking.status.ilike('booked'), Booking.status.ilike('checked-in')),
    Booking.check_in < end_date,
    Booking.check_out > start_date
).all()

if conflicts:
    for b in conflicts:
        print(f"CONFLICT FOUND: ID={b.id}, Guest='{b.guest_name}', Dates={b.check_in} to {b.check_out}, Status='{b.status}'")
else:
    print("No conflicts found. The room should be available.")
