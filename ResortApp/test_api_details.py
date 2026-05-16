import os
import sys
import json

# Add project root to path
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.api.booking import get_booking_details
from app.models.user import User

db = SessionLocal()
test_user = db.query(User).first()

print("--- TESTING API DETAILS FOR BOOKING 48 ---")
try:
    # Simulate API call
    # get_booking_details(booking_id, is_package, db, current_user, branch_id)
    details = get_booking_details(
        booking_id=48, 
        is_package=False, 
        db=db, 
        current_user=test_user, 
        branch_id=test_user.branch_id
    )
    print(f"Guest: {details.guest_name}")
    print(f"Payments count: {len(details.payments)}")
    for p in details.payments:
        print(f"  - Amount: {p.amount}, Method: {p.method}")
except Exception as e:
    print(f"API Error: {e}")
finally:
    db.close()
