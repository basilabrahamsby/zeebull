from app.database import SessionLocal
from app.models.inventory import LocationStock, InventoryItem, Location

db = SessionLocal()
print("--- Location Stock ---")
stocks = db.query(LocationStock).all()
for s in stocks:
    item = db.query(InventoryItem).get(s.item_id)
    loc = db.query(Location).get(s.location_id)
    if s.quantity > 0 and item and loc:
        print(f"Item: {item.name}, Loc: {loc.name}, Qty: {s.quantity}, LocIsInv: {loc.is_inventory_point}")
db.close()
