import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.Package import PackageBooking

db = SessionLocal()
try:
    booking = db.query(PackageBooking).filter(PackageBooking.id == 5).first()
    if booking:
        print("=== Booking 5 Details ===")
        for col in booking.__table__.columns:
            print(f"{col.name}: {getattr(booking, col.name)}")
        print(f"package: {booking.package.title if booking.package else 'None'}")
        print(f"package room_types: {booking.package.room_types if booking.package else 'None'}")
        print(f"package booking_type: {booking.package.booking_type if booking.package else 'None'}")
    else:
        print("Booking 5 not found")
except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()
