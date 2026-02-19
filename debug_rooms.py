
import sys
import os
current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.room import Room
from app.models.inventory import Location

db = SessionLocal()

print("--- ROOM INFO ---")
rooms = db.query(Room).all()
for r in rooms:
    loc = db.query(Location).filter(Location.id == r.inventory_location_id).first()
    print(f"Room ID: {r.id}, Number: {r.number}, Inventory Loc ID: {r.inventory_location_id}, Loc Name: {loc.name if loc else 'N/A'}")

db.close()
