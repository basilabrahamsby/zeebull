import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.Package import PackageBooking

db = SessionLocal()
try:
    booking = db.query(PackageBooking).filter(PackageBooking.id == 4).first()
    if booking:
        print(f"Booking ID: {booking.id}")
        print(f"  Guest Name: {booking.guest_name}")
        print(f"  Status: {booking.status}")
        print(f"  Checked In At: {booking.checked_in_at}")
        print(f"  Confirmed At: {booking.confirmed_at}")
        print(f"  Check In Date: {booking.check_in}")
        print(f"  Check Out Date: {booking.check_out}")
    else:
        print("Booking not found")
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
