import sys
import os

# Add ResortApp to path so 'app' module can be found
current_dir = os.getcwd()
if os.path.basename(current_dir) == "New Orchid":
    sys.path.append(os.path.join(current_dir, "ResortApp"))

from app.database import SessionLocal
from app.models.inventory import LocationStock, AssetMapping, Location

db = SessionLocal()

print("Scanning for Guest Rooms...")
# Find all Guest Rooms
guest_rooms = db.query(Location).filter(Location.location_type == "GUEST_ROOM").all()
room_ids = [r.id for r in guest_rooms]

if not room_ids:
    print("No guest rooms found.")
    db.close()
    exit()

print(f"Found {len(room_ids)} guest rooms.")

# Delete Stock in Rooms
stocks = db.query(LocationStock).filter(LocationStock.location_id.in_(room_ids)).all()
if stocks:
    print(f"Deleting {len(stocks)} stock records from rooms...")
    for s in stocks:
        db.delete(s)
else:
    print("No stock found in rooms.")

# Delete Asset Mappings in Rooms
mappings = db.query(AssetMapping).filter(AssetMapping.location_id.in_(room_ids)).all()
if mappings:
    print(f"Deleting {len(mappings)} asset mappings from rooms...")
    for m in mappings:
        db.delete(m)
else:
    print("No asset mappings found in rooms.")

db.commit()
print("Cleanup Complete. Items removed from system.")
db.close()
