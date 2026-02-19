
import sys
import os
import json
from datetime import date, datetime

def default_json(obj):
    if isinstance(obj, (date, datetime)):
        return obj.isoformat()
    return str(obj)

current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.service_request import ServiceRequest
from app.models.inventory import AssetMapping, InventoryItem, Location, LocationStock
from sqlalchemy import desc

db = SessionLocal()

print("--- REPLENISHMENT REQUESTS ---")
reqs = db.query(ServiceRequest).filter(ServiceRequest.request_type == "replenishment").order_by(desc(ServiceRequest.id)).limit(10).all()
for r in reqs:
    print(f"ID: {r.id}, Status: {r.status}, RoomID: {r.room_id}, Completed: {r.completed_at}")
    if r.refill_data:
        try:
            data = json.loads(r.refill_data) if isinstance(r.refill_data, str) else r.refill_data
            print(f"  Refill Data: {json.dumps(data, indent=2)}")
        except:
            print(f"  Refill Data (raw): {r.refill_data}")

# Check Room 200 explicitly
room_loc = db.query(Location).filter(Location.name == "Room 200").first()
if room_loc:
    print(f"\n--- ROOM 200 (ID: {room_loc.id}) STATE ---")
    mappings = db.query(AssetMapping).filter(AssetMapping.location_id == room_loc.id).all()
    for m in mappings:
        item = db.query(InventoryItem).filter(InventoryItem.id == m.item_id).first()
        print(f"  AssetMapping: {item.name if item else m.item_id} (Active: {m.is_active}, Qty: {m.quantity})")
    
    stocks = db.query(LocationStock).filter(LocationStock.location_id == room_loc.id).all()
    for s in stocks:
        item = db.query(InventoryItem).filter(InventoryItem.id == s.item_id).first()
        print(f"  Stock: {item.name if item else s.item_id} (Qty: {s.quantity})")
else:
    print("\nRoom 200 location not found")

db.close()
