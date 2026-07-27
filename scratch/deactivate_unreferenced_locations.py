import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.room import Room
from app.models.inventory import Location

db = SessionLocal()

print('=== DEACTIVATING UNREFERENCED GUEST ROOM LOCATIONS ===')
target_ids = [1, 2, 4, 5, 17]
updated = 0
for tid in target_ids:
    loc = db.query(Location).filter(Location.id == tid).first()
    if loc:
        print(f"Deactivating location: {loc.name} (Location ID: {loc.id}, Branch ID: {loc.branch_id})")
        loc.is_active = False
        updated += 1

if updated > 0:
    db.commit()
    print(f"Successfully deactivated {updated} unreferenced room locations.")
else:
    print("No unreferenced room locations to deactivate.")

db.close()
