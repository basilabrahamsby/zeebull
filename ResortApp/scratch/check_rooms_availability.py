import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.room import Room, RoomType
from app.models.Package import PackageBooking

db = SessionLocal()
try:
    print("--- Room Types ---")
    types = db.query(RoomType).all()
    for t in types:
        print(f"ID: {t.id} | Name: '{t.name}' | Branch ID: {t.branch_id}")

    print("\n--- Rooms ---")
    rooms = db.query(Room).all()
    print(f"Total Rooms: {len(rooms)}")
    for r in rooms:
        print(f"Room ID: {r.id} | Number: {r.number} | Type ID: {r.room_type_id} | Type Name: '{r.type}' | Status: {r.status}")

    print("\n--- Recent Package Bookings ---")
    bookings = db.query(PackageBooking).order_by(PackageBooking.id.desc()).limit(10).all()
    for b in bookings:
        print(f"ID: {b.id} | Guest Name: {b.guest_name} | Room Type ID: {getattr(b, 'room_type_id', 'N/A')} | Status: {b.status} | Num Rooms: {b.num_rooms}")

except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()
