
import os
import sys

# Force UTF-8 output
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

# Add the project root to sys.path
sys.path.append(os.path.join(os.getcwd(), "ResortApp"))

from app.database import SessionLocal
from app.models.inventory import InventoryItem

def check_item(item_id):
    db = SessionLocal()
    try:
        item = db.query(InventoryItem).filter(InventoryItem.id == item_id).first()
        if not item:
            print(f"Item {item_id} not found")
            return

        print(f"Item: {item.name} (ID: {item.id})")
        print(f"Is Asset Fixed: {item.is_asset_fixed}")
        print(f"Selling Price: {item.selling_price}")
        print(f"Unit Price: {item.unit_price}")
        print(f"Category: {item.category.name if item.category else 'N/A'}")
        
    finally:
        db.close()

if __name__ == "__main__":
    check_item(22) # Tube Light
    print("---")
    check_item(27) # Likely 3-Pin Plug? I'll check common IDs if I can.
    # I'll just search for 3-Pin Plug
    db = SessionLocal()
    item = db.query(InventoryItem).filter(InventoryItem.name.ilike("%3-Pin Plug%")).first()
    if item:
        check_item(item.id)
    db.close()
