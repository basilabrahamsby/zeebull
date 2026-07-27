import os
import sys

# Add ResortApp to python path
sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.room import Room
from app.models.inventory import Location

db = SessionLocal()

print('=== ROOM TO LOCATION MAPPING ===')
rooms = db.query(Room).all()
for r in rooms:
    loc = db.query(Location).filter(Location.id == r.inventory_location_id).first()
    if loc:
        mismatch = "MISMATCH!" if r.branch_id != loc.branch_id else "OK"
        print(f"Room: {r.number} (Branch ID: {r.branch_id}) -> Location: {loc.name} (Location ID: {loc.id}, Branch ID: {loc.branch_id}) | Status: {mismatch}")
    else:
        print(f"Room: {r.number} (Branch ID: {r.branch_id}) -> Location: None")

db.close()
