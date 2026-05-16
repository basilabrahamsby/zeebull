import os
import sys

# Add project root to path
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.booking import Booking
from app.models.Package import PackageBooking
from app.models.payment import Payment
from sqlalchemy import func

db = SessionLocal()

print("--- HEALING ADVANCE DEPOSITS ---")

# Fix Regular Bookings
regular_bookings = db.query(Booking).all()
for b in regular_bookings:
    total_paid = db.query(func.sum(Payment.amount)).filter(Payment.booking_id == b.id).scalar() or 0.0
    if b.advance_deposit != total_paid:
        print(f"Fixing Booking {b.id}: {b.advance_deposit} -> {total_paid}")
        b.advance_deposit = total_paid

# Fix Package Bookings
pkg_bookings = db.query(PackageBooking).all()
for b in pkg_bookings:
    total_paid = db.query(func.sum(Payment.amount)).filter(Payment.package_booking_id == b.id).scalar() or 0.0
    if b.advance_deposit != total_paid:
        print(f"Fixing Package Booking {b.id}: {b.advance_deposit} -> {total_paid}")
        b.advance_deposit = total_paid

db.commit()
db.close()
