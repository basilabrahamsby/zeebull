import os
import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
from app.api.booking import create_booking
from app.schemas.booking import BookingCreate

load_dotenv('D:/Zeebull/ResortApp/.env')
engine = create_engine(os.getenv("DATABASE_URL"))
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def test_booking():
    db = SessionLocal()
    try:
        # Mocking user
        class MockUser:
            id = 1
        
        # Test creating booking with custom room rate
        # 3000 inclusive
        b_in = BookingCreate(
            guest_name="Test Inclusive Booking",
            guest_mobile="1234567890",
            check_in=datetime.date.today(),
            check_out=datetime.date.today() + datetime.timedelta(days=1),
            adults=2,
            children=0,
            room_type_id=1,
            num_rooms=1,
            room_ids=[101], # Assume room 101 exists
            custom_room_rate=3000.0,
            source="Test"
        )
        
        b_out = create_booking(booking=b_in, db=db, current_user=MockUser(), branch_id=1)
        print(f"Created Booking ID: {b_out.id}")
        print(f"Total Amount: {b_out.total_amount}")
        print(f"Room Rate: {b_out.room_rate}")
        db.commit()
    except Exception as e:
        print("Error:", e)
        db.rollback()
    finally:
        db.close()

test_booking()
