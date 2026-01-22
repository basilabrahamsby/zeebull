from app.database import SessionLocal
from app.models.inventory import InventoryItem

db = SessionLocal()
items = db.query(InventoryItem).all()

for item in items:
    print(f"ID: {item.id}, Name: {item.name}")
    print(f"  Unit Price: {item.unit_price}")
    print(f"  Selling Price: {item.selling_price}")
    print(f"  Is Asset Fixed: {item.is_asset_fixed}")
    print("-" * 20)

db.close()
