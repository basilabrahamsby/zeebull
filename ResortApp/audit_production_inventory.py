import sys
import os
from datetime import date

# Add the current directory to sys.path to allow imports from app
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.room import RoomType, Room
from app.models.booking import Booking, BookingRoom
from sqlalchemy import or_

from app.models.Package import PackageBooking, PackageBookingRoom

def audit_inventory(room_type_id: int):
    db = SessionLocal()
    try:
        from app.models.user import User
        users = db.query(User).all()
        print("Users in Database:")
        for u in users:
            print(f"  - ID: {u.id}, Name: {u.name}, Email: {u.email}, Branch ID: {u.branch_id}, Superadmin: {u.is_superadmin}")
        
        print(f"Total Bookings in Database: {db.query(Booking).count()}")
        room_type = db.query(RoomType).filter(RoomType.id == room_type_id).first()
        if not room_type:
            print(f"RoomType {room_type_id} not found.")
            return

        print(f"--- AUDIT FOR: {room_type.name} (ID: {room_type_id}) ---")
        print(f"Online Inventory (Quota): {room_type.online_inventory}")
        
        target_date = date.today()
        print(f"Target Date: {target_date}")

        # Total Physical Capacity
        capacity = db.query(Room).filter(Room.room_type_id == room_type_id, Room.status != 'Deleted').count()
        print(f"Total Physical Capacity: {capacity}")

        # Active Statuses
        ACTIVE_STATUSES = ["Booked", "booked", "checked-in", "Checked-in", "Confirmed", "confirmed", "Occupied", "occupied"]
        
        # 1. Hard allocations (Regular)
        assigned_bookings = db.query(BookingRoom).join(Booking).join(Room).filter(
            Room.room_type_id == room_type_id,
            Booking.status.in_(ACTIVE_STATUSES),
            Booking.check_in <= target_date,
            Booking.check_out > target_date
        ).all()
        
        print(f"\nHard Assigned Regular Bookings ({len(assigned_bookings)}):")
        for br in assigned_bookings:
            b = br.booking
            r = br.room
            print(f"  - Booking ID: {b.id}, Guest: {b.guest_name}, Status: {b.status}, Room: {r.number}, Dates: {b.check_in} to {b.check_out}")

        # 2. Hard allocations (Packages)
        assigned_packages = db.query(PackageBookingRoom).join(PackageBooking).join(Room).filter(
            Room.room_type_id == room_type_id,
            PackageBooking.status.in_(ACTIVE_STATUSES),
            PackageBooking.check_in <= target_date,
            PackageBooking.check_out > target_date
        ).all()
        
        print(f"\nHard Assigned Package Bookings ({len(assigned_packages)}):")
        for pbr in assigned_packages:
            pb = pbr.package_booking
            r = pbr.room
            print(f"  - Pkg Booking ID: {pb.id}, Guest: {pb.guest_name}, Status: {pb.status}, Room: {r.number}, Dates: {pb.check_in} to {pb.check_out}")

        # 3. Regular Soft allocations
        all_bookings_of_type = db.query(Booking).filter(
            Booking.room_type_id == room_type_id,
            Booking.status.in_(ACTIVE_STATUSES),
            Booking.check_in <= target_date,
            Booking.check_out > target_date
        ).all()

        print(f"\nActive Regular Bookings of Type ({len(all_bookings_of_type)}):")
        total_regular_soft_remainder = 0
        for b in all_bookings_of_type:
            num_assigned_this_type = db.query(BookingRoom).join(Room).filter(
                BookingRoom.booking_id == b.id,
                Room.room_type_id == room_type_id
            ).count()
            
            remainder = max(0, (b.num_rooms or 1) - num_assigned_this_type)
            total_regular_soft_remainder += remainder
            print(f"  - Booking ID: {b.id}, Display ID: {b.display_id}, Guest: {b.guest_name}, Status: {repr(b.status)}, Rooms: {b.num_rooms}, Remainder: {remainder}, Dates: {b.check_in} to {b.check_out}, Source: {b.source}")

        # 4. Package Soft allocations (if the package includes this room type)
        # Packages don't have room_type_id directly, they have room_types string or implied
        # For now, let's just look for any PackageBooking that has rooms assigned of this type
        # or where the package title might suggest it.
        # This is complex, but let's at least count the assigned ones.
        
        total_bookings_counted = len(assigned_bookings) + len(assigned_packages) + total_regular_soft_remainder
        print(f"\nTotal Bookings Counted for Inventory: {total_bookings_counted}")
        
        physical_free = max(0, capacity - total_bookings_counted)
        print(f"Physical Free: {physical_free}")

        if room_type.online_inventory is not None:
            ota_calc = max(0, room_type.online_inventory - total_bookings_counted)
            ota_final = min(ota_calc, physical_free)
            print(f"OTA Calculated Availability: {ota_calc}")
            print(f"OTA Final (Capped by Physical): {ota_final}")

    finally:
        db.close()

if __name__ == "__main__":
    # If no ID provided, list all first
    if len(sys.argv) < 2:
        db = SessionLocal()
        rts = db.query(RoomType).all()
        print("Available Room Types:")
        for rt in rts:
            print(f"ID: {rt.id}, Name: {rt.name}")
        db.close()
    else:
        audit_inventory(int(sys.argv[1]))
