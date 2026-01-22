import sys
import os
sys.path.append(os.getcwd())
sys.path.append(os.path.join(os.getcwd(), 'ResortApp'))

from ResortApp.app.database import SessionLocal
from ResortApp.app.models.checkout import CheckoutRequest

db = SessionLocal()
req = db.query(CheckoutRequest).filter(CheckoutRequest.room_number == '101').order_by(CheckoutRequest.id.desc()).first()

if req and req.inventory_data:
    found_corrected = False
    for item in req.inventory_data:
        # Check specifically for the LED bulb or Smart TV which had issues
        if item.get('item_name') in ['LED bulb', 'SMART TV'] and item.get('allocated_stock') == 1.0:
            found_corrected = True
            print(f"VERIFIED: {item.get('item_name')} has allocated_stock=1.0")
    
    if found_corrected:
        print("DATABASE RESTORE SUCCESSFUL: Data matches server fix.")
    else:
        print("WARNING: Could not find corrected data in local DB.")
else:
    print("No data found.")
