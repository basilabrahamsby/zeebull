import sys
import os
# Add current directory to path
sys.path.append(os.getcwd())
# Adjust path to find ResortApp module if needed
sys.path.append(os.path.join(os.getcwd(), 'ResortApp'))

from ResortApp.app.database import SessionLocal
from ResortApp.app.models.checkout import CheckoutRequest

try:
    db = SessionLocal()
    req = db.query(CheckoutRequest).filter(CheckoutRequest.room_number == '101').order_by(CheckoutRequest.id.desc()).first()
    if req:
        print(f"Checkout Request ID: {req.id}")
        data = req.inventory_data
        if data:
            print(f"Inventory Data Count: {len(data)}")
            for item in data:
                 if item.get('allocated_stock') == 1.0:
                     print("Found corrected item with allocated_stock=1.0")
                     print(item)
    else:
        print("No checkout request found for room 101")
except Exception as e:
    print(f"Error: {e}")
