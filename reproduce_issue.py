import sys
import os
import datetime
# Path setup
sys.path.append(os.getcwd())
sys.path.append(os.path.join(os.getcwd(), 'ResortApp'))

from app.database import SessionLocal
from app.api.checkout import CheckoutRequestModel
from app.models.room import Room
from app.api.checkout import _calculate_bill_for_single_room

from app.schemas.checkout import BillSummary


db = SessionLocal()
room_number = "101"
req = db.query(CheckoutRequestModel).filter(CheckoutRequestModel.room_number == room_number).order_by(CheckoutRequestModel.id.desc()).first()
room = db.query(Room).filter(Room.number == room_number).first()

if req and room:
    print(f"Request ID: {req.id}")
    # Mock dates
    check_in = datetime.datetime.now() - datetime.timedelta(days=1)
    check_out = datetime.datetime.now()
    
    # Run logic
    try:
        bill = _calculate_bill_for_single_room(db, room, req, check_in, check_out)
        print("\n--- INVENTORY USAGE ---")
        for item in bill.inventory_usage:
            print(f"Item: {item.item_name}, Qty: {item.quantity}, Price: {item.rental_price}, Charge: {item.rental_charge}")
            
        print("\n--- ASSET DAMAGES ---")
        for item in bill.asset_damages:
             print(f"Item: {item.item_name}, Cost: {item.replacement_cost}")

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
else:
    print("Req or Room not found")
