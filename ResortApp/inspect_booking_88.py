import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.booking import Booking, BookingRoom
from app.database import SQLALCHEMY_DATABASE_URL

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

try:
    booking = db.query(Booking).filter(Booking.id == 88).first()
    if not booking:
        print("Booking ID 88 not found!")
        sys.exit(0)
        
    print(f"Booking ID: {booking.id}")
    print(f"Display ID: {booking.display_id}")
    print(f"Guest Name: {booking.guest_name}")
    print(f"Status: {booking.status}")
    print(f"Check In: {booking.check_in}, Check Out: {booking.check_out}")
    print(f"Checked In At: {booking.checked_in_at}, Checked Out At: {booking.checked_out_at}")
    
    print("\nBooking Rooms:")
    for br in booking.booking_rooms:
        print(f"  - BookingRoom ID: {br.id}, Room ID: {br.room_id}, Room Number: {br.room.number if br.room else 'None'}, Room Status: {br.room.status if br.room else 'None'}")
        
    print("\nCheckout info:")
    if booking.checkout:
        print(f"  - Checkout ID: {booking.checkout.id}")
        print(f"  - Checkout Status: {getattr(booking.checkout, 'status', 'None')}")
        print(f"  - Checked Out At: {getattr(booking.checkout, 'created_at', 'None')}")
    else:
        print("  - No direct booking.checkout relation")
        
    # Let's also check if there are other checkouts associated with this booking
    # In some designs, checkouts might be recorded per room or booking
    from sqlalchemy import text
    try:
        # Check checkout tables or checkouts table structure
        res = db.execute(text("SELECT * FROM checkouts WHERE booking_id = 88")).all()
        print(f"\nRaw Checkouts for Booking 88 (Count: {len(res)}):")
        for row in res:
            print("  -", dict(row._mapping))
    except Exception as e:
        print("Error querying checkouts table directly:", e)
        
    try:
        # Let's check room checkouts or similar
        res = db.execute(text("SELECT * FROM room_checkouts WHERE booking_id = 88")).all()
        print(f"\nRaw Room Checkouts for Booking 88 (Count: {len(res)}):")
        for row in res:
            print("  -", dict(row._mapping))
    except Exception as e:
        print("No room_checkouts table or error:", e)

finally:
    db.close()
