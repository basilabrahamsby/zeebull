from app.database import SessionLocal
from app.models.inventory import LocationStock, InventoryItem, Location

db = SessionLocal()

print("--- Checking Room 101 ---")
room101 = db.query(Location).filter(Location.name.like("%101%")).first()
if room101:
    print(f"Found: {room101.name}, ID: {room101.id}, IsInv: {room101.is_inventory_point}")
    # Check stocks
    stocks = db.query(LocationStock).filter(LocationStock.location_id == room101.id).all()
    print(f"Stocks in Room 101: {len(stocks)}")
    for s in stocks:
        print(f" - Item: {s.item_id}, Qty: {s.quantity}")
else:
    print("Room 101 not found")

print("\n--- Checking Filter Logic ---")
non_inv_stocks = db.query(LocationStock).join(Location).filter(Location.is_inventory_point == False).all()
print(f"Stocks passing 'is_inventory_point == False': {len(non_inv_stocks)}")
for s in non_inv_stocks:
    print(f" PASS: Loc {s.location.name}, Qty {s.quantity}")

db.close()
