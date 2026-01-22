import sys
import os

# Set up path to find 'app' module
sys.path.append("/var/www/inventory/ResortApp")

from app.database import SessionLocal
from app.models.booking import Booking
from app.models.Package import PackageBooking

try:
    db = SessionLocal()
    b = db.query(Booking).filter(Booking.id == 1).first()
    p = db.query(PackageBooking).filter(PackageBooking.id == 1).first()

    print(f"Booking 1 Exists: {b is not None}")
    if b:
        print(f"Booking 1 Status: {b.status}")
        
    print(f"PackageBooking 1 Exists: {p is not None}")
    if p:
        print(f"PackageBooking 1 Status: {p.status}")

except Exception as e:
    print(f"Error: {e}")
