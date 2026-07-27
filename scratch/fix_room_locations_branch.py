import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.room import Room
from app.models.inventory import Location

db = SessionLocal()

print('=== FIXING ROOM LOCATIONS BRANCH ID ===')
rooms = db.query(Room).all()
updated_count = 0
for r in rooms:
    loc = db.query(Location).filter(Location.id == r.inventory_location_id).first()
    if loc:
        if r.branch_id != loc.branch_id:
            print(f"Room: {r.number} (Branch ID: {r.branch_id}) -> Location: {loc.name} (Location ID: {loc.id}, Old Branch ID: {loc.branch_id})")
            loc.branch_id = r.branch_id
            updated_count += 1

if updated_count > 0:
    db.commit()
    print(f"Successfully updated {updated_count} location records.")
else:
    print("No mismatches found.")

db.close()
