import os
from sqlalchemy import create_engine, func
from sqlalchemy.orm import sessionmaker
from app.models.booking import Booking
from app.database import SQLALCHEMY_DATABASE_URL

print("Connecting to database...")
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

try:
    print("Querying duplicate bookings...")
    # Find bookings with external_id that are not null and have duplicate entries
    duplicates = db.query(Booking.external_id).filter(Booking.external_id.isnot(None)).group_by(Booking.external_id).having(func.count(Booking.id) > 1).all()
    
    if not duplicates:
        print("No duplicate bookings found in the database!")
    else:
        print(f"Found {len(duplicates)} duplicate external_id groups:")
        for dup in duplicates:
            ext_id = dup[0]
            bookings = db.query(Booking).filter(Booking.external_id == ext_id).order_by(Booking.id).all()
            print(f"\nExternal ID: {ext_id} (Count: {len(bookings)})")
            for b in bookings:
                print(f"  - Booking ID: {b.id}, Display ID: {b.display_id}, Guest: {b.guest_name}, Status: {b.status}, Created At: {b.created_at}")
                # Check for dependencies
                booking_rooms_count = len(b.booking_rooms)
                payments_count = len(b.payments) if hasattr(b, 'payments') else 0
                has_checkout = b.checkout is not None
                print(f"    Dependencies: booking_rooms={booking_rooms_count}, payments={payments_count}, checkout={has_checkout}")
finally:
    db.close()
