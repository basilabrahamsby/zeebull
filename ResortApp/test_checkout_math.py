import asyncio
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.booking import Booking
from app.models.room import Room
from app.api.checkout import get_bill_for_booking, process_booking_checkout
from app.schemas.checkout import CheckoutRequest

def test_math():
    db = SessionLocal()
    try:
        req = CheckoutRequest(
            checkout_mode="single",
            payment_method="Cash",
            discount_amount=0,
            tips_gratuity=0
        )
        
        from app.models.user import User
        mock_user = User(id=1, email="test@test.com")
        from fastapi import BackgroundTasks
        bt = BackgroundTasks()
        
        # Manually force room to not be available so it runs the full logic
        room = db.query(Room).filter(Room.number == "201").first()
        old_status = room.status
        room.status = "Occupied"
        db.commit()
        
        print("\nPROCESS CHECKOUT")
        res = process_booking_checkout("201", req, bt, db, mock_user, 1)
        print(f"Grand Total Saved: {res.grand_total}")
        
        # Revert
        room.status = old_status
        db.commit()
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.rollback()
        db.close()

if __name__ == "__main__":
    test_math()
