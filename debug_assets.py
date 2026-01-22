from app.database import SessionLocal
from app.models.inventory import Location, AssetMapping, InventoryItem

db = SessionLocal()
print("--- Locations ---")
locs = db.query(Location).all()
for l in locs:
    print(f"ID: {l.id}, Name: {l.name}, Type: {l.location_type}, IsInvPoint: {l.is_inventory_point}")

print("\n--- Asset Mappings ---")
mappings = db.query(AssetMapping).all()
for m in mappings:
    loc = db.query(Location).get(m.location_id)
    item = db.query(InventoryItem).get(m.item_id)
    if loc and item:
        print(f"Mapping ID: {m.id}, Item: {item.name}, Loc: {loc.name}, LocIsInv: {loc.is_inventory_point}")
    else:
        print(f"Mapping ID: {m.id}, Data Missing")

db.close()
