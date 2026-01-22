
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
from app.models.room import Room

def check_verification_data(room_number):
    db = SessionLocal()
    try:
        room = db.query(Room).filter(Room.number == room_number).first()
        if not room:
            print(f"Room {room_number} not found")
            return

        requests = db.query(CheckoutRequestModel).filter(
            CheckoutRequestModel.room_number == room_number
        ).order_by(CheckoutRequestModel.id.desc()).all()

        for req in requests:
            print(f"REQ_START|{req.id}|{req.status}|{req.inventory_checked}|{req.inventory_checked_by}|{req.inventory_checked_at}")
            if req.inventory_data:
                for item in req.inventory_data:
                    used = item.get('used_qty', 0)
                    missing = item.get('missing_qty', 0)
                    damage = item.get('damage_qty', 0)
                    charge = item.get('missing_item_charge', 0) or item.get('damage_charge', 0)
                    name = item.get('item_name', 'Unknown')
                    if used > 0 or missing > 0 or damage > 0 or charge > 0:
                        print(f"ITEM|{name}|{used}|{missing}|{damage}|{charge}")
            print("REQ_END")

    finally:
        db.close()

if __name__ == "__main__":
    check_verification_data("101")
