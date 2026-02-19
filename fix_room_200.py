
import sys
import os
import json
from datetime import datetime

current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.inventory import AssetMapping, LocationStock, Location, InventoryItem

db = SessionLocal()

# Room 200 has Inventory Location ID 19
loc_id = 19
item_name = "bed sheet"

item = db.query(InventoryItem).filter(InventoryItem.name == item_name).first()
if item:
    print(f"Fixing {item_name} (ID: {item.id}) for Room 200 (Loc: {loc_id})")
    
    # 1. Update/Add LocationStock
    stock = db.query(LocationStock).filter(LocationStock.location_id == loc_id, LocationStock.item_id == item.id).first()
    if stock:
        stock.quantity = 1.0
        stock.last_updated = datetime.utcnow()
        print("Updated LocationStock to 1.0")
    else:
        db.add(LocationStock(location_id=loc_id, item_id=item.id, quantity=1.0, last_updated=datetime.utcnow()))
        print("Added new LocationStock entry with quantity 1.0")
    
    # 2. Update/Add AssetMapping
    mapping = db.query(AssetMapping).filter(AssetMapping.location_id == loc_id, AssetMapping.item_id == item.id).first()
    if mapping:
        mapping.is_active = True
        mapping.quantity = 1.0
        print("Activated AssetMapping")
    else:
        db.add(AssetMapping(location_id=loc_id, item_id=item.id, is_active=True, quantity=1.0))
        print("Added new AssetMapping entry")
    
    db.commit()
    print("Changes committed.")
else:
    print(f"Item {item_name} not found.")

db.close()
