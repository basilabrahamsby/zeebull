import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.room import Room
from app.models.inventory import Location, LocationStock

db = SessionLocal()

print('=== UNREFERENCED GUEST ROOM LOCATIONS AND THEIR STOCK ===')
locations = db.query(Location).filter(Location.location_type == 'GUEST_ROOM').all()
for l in locations:
    room = db.query(Room).filter(Room.inventory_location_id == l.id).first()
    if not room:
        # Check stock
        stocks = db.query(LocationStock).filter(LocationStock.location_id == l.id).all()
        stock_summary = ", ".join([f"Item ID {s.item_id}: {s.quantity} qty" for s in stocks]) if stocks else "None"
        print(f"Location ID: {l.id}, Name: {l.name}, Branch ID: {l.branch_id}, Stock: {stock_summary}")

db.close()
