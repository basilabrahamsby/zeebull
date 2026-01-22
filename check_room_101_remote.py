
import os
import sys
import json

# Force UTF-8 output
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

# Add the project root to sys.path
sys.path.append(os.path.join(os.getcwd(), "ResortApp"))

from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.checkout import CheckoutRequest as CheckoutRequestModel

def check_verification_data(room_number):
    db = SessionLocal()
    try:
        requests = db.query(CheckoutRequestModel).filter(
            CheckoutRequestModel.room_number == room_number
        ).order_by(CheckoutRequestModel.id.desc()).all()

        for req in requests:
            print(f"REQ|ID:{req.id}|Status:{req.status}|By:{req.inventory_checked_by}|At:{req.inventory_checked_at}")
            
    finally:
        db.close()

if __name__ == "__main__":
    check_verification_data("101")
