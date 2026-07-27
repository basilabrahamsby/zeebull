import os
import sys
from datetime import date

# Add project root to path
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.room import RoomType, Room
from app.models.booking import Booking, BookingRoom
from app.models.Package import PackageBooking, PackageBookingRoom

db = SessionLocal()

# Find the Heritage room type
room_types = db.query(RoomType).all()
heritage_rt = None
for rt in room_types:
    print(f"RoomType ID: {rt.id}, Name: {rt.name}, ChannelManagerID: {rt.channel_manager_id}, Online Inventory: {rt.online_inventory}")
    if "heritage" in rt.name.lower():
        heritage_rt = rt

if not heritage_rt:
    print("Heritage room type not found.")
    db.close()
    sys.exit(0)

target_date = date(2026, 7, 11)
print(f"\n--- CHECKING AVAILABILITY FOR {heritage_rt.name} (ID: {heritage_rt.id}) ON {target_date} ---")

# 1. Total physical rooms
total_physical = db.query(Room).filter(
    Room.room_type_id == heritage_rt.id,
    Room.status.notin_(["Deleted", "Maintenance", "Out of Order"])
).all()
print(f"Physical rooms found (not deleted/maintenance): {len(total_physical)}")
for r in total_physical:
    print(f"  - Room ID: {r.id}, Number: {r.number}, Status: {r.status}")

# 2. Hard allocations (BookingRoom)
assigned_overlaps = db.query(BookingRoom).join(Booking).join(Room).filter(
    Room.room_type_id == heritage_rt.id,
    Booking.status.in_(["Booked", "booked", "checked-in", "Checked-in", "Confirmed", "confirmed", "Occupied", "occupied"]),
    Booking.check_in <= target_date,
    Booking.check_out > target_date
).all()
print(f"\nHard allocations found: {len(assigned_overlaps)}")
for ar in assigned_overlaps:
    print(f"  - Booking ID: {ar.booking_id}, Room ID: {ar.room_id}, Room Number: {ar.room.number if ar.room else 'None'}, Status: {ar.booking.status}")

# 3. All bookings on this date of this type
bookings_of_type = db.query(Booking).filter(
    Booking.room_type_id == heritage_rt.id,
    Booking.status.in_(["Booked", "booked", "checked-in", "Checked-in", "Confirmed", "confirmed", "Occupied", "occupied"]),
    Booking.check_in <= target_date,
    Booking.check_out > target_date
).all()
print(f"\nAll Active Bookings of this type on this date: {len(bookings_of_type)}")
for b in bookings_of_type:
    print(f"  - Booking ID: {b.id}, Guest: {b.guest_id}, DisplayID: {b.display_id}, Num Rooms: {b.num_rooms}, CheckIn: {b.check_in}, CheckOut: {b.check_out}, Source: {b.source}, Status: {b.status}")

# 4. Soft allocations calculation
soft_remainder = 0
for b in bookings_of_type:
    num_assigned_this_type = db.query(BookingRoom).join(Room).filter(
        BookingRoom.booking_id == b.id,
        Room.room_type_id == heritage_rt.id
    ).count()
    rem = max(0, (b.num_rooms or 1) - num_assigned_this_type)
    print(f"    Booking {b.id} ({b.display_id}): Num Rooms = {b.num_rooms}, Assigned of type = {num_assigned_this_type} -> Soft Remainder = {rem}")
    soft_remainder += rem

print(f"\nTotal Soft Remainder: {soft_remainder}")

# 5. Let's run the exact calculation function from aiosell_triggers
from app.core.aiosell_triggers import _calculate_availability_for_date
avail = _calculate_availability_for_date(db, heritage_rt.id, target_date)
print(f"\nEVALUATED AVAILABILITY: {avail}")

db.close()
