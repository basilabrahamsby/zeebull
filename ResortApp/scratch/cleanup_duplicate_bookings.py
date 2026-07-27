import os
import sys
from pathlib import Path

# Set up python path so we can import from 'app'
current_file = Path(__file__).resolve()
resort_app_dir = current_file.parent.parent
if str(resort_app_dir) not in sys.path:
    sys.path.insert(0, str(resort_app_dir))

from sqlalchemy import create_engine, func
from sqlalchemy.orm import sessionmaker
from app.models.booking import Booking, BookingRoom
from app.database import SQLALCHEMY_DATABASE_URL

print("Connecting to database...")
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

try:
    print("Finding duplicate bookings...")
    # Find bookings with external_id that have duplicate entries
    duplicates = db.query(Booking.external_id).filter(Booking.external_id.isnot(None)).group_by(Booking.external_id).having(func.count(Booking.id) > 1).all()
    
    if not duplicates:
        print("No duplicate bookings found in the database. Nothing to clean up!")
        sys.exit(0)
        
    print(f"Found {len(duplicates)} duplicate external_id groups to clean up:")
    
    total_deleted = 0
    for dup in duplicates:
        ext_id = dup[0]
        # Query all bookings for this external_id, sorted by id (earliest first)
        bookings = db.query(Booking).filter(Booking.external_id == ext_id).order_by(Booking.id).all()
        
        # Keep the first one, delete the rest
        keeper = bookings[0]
        to_delete = bookings[1:]
        
        print(f"\nGroup external_id: '{ext_id}'")
        print(f"  [KEEP] ID: {keeper.id}, Display ID: {keeper.display_id}, Guest: {keeper.guest_name}, Status: {keeper.status}, Created: {keeper.created_at}")
        
        for b in to_delete:
            print(f"  [DELETE] ID: {b.id}, Display ID: {b.display_id}, Guest: {b.guest_name}, Status: {b.status}, Created: {b.created_at}")
            
            # Double check for associated rooms to delete orphans/cleanup cascade
            if b.booking_rooms:
                print(f"    - Cleaning up {len(b.booking_rooms)} associated booking_rooms records...")
                for br in b.booking_rooms:
                    db.delete(br)
            
            # Perform deletion
            db.delete(b)
            total_deleted += 1
            
    print("\nCommitting changes to database...")
    db.commit()
    print(f"Success! Cleaned up {total_deleted} duplicate bookings from the database.")
    
except Exception as e:
    print(f"Error during cleanup: {e}")
    db.rollback()
    sys.exit(1)
finally:
    db.close()
