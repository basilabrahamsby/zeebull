
import os
import sys

# Force UTF-8 output
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

# Add the project root to sys.path
sys.path.append(os.path.join(os.getcwd(), "ResortApp"))

from app.database import SessionLocal
from app.models.inventory import InventoryItem

def check_items():
    db = SessionLocal()
    try:
        items = db.query(InventoryItem).filter(
            (InventoryItem.name.ilike("%SMART TV%")) | 
            (InventoryItem.name.ilike("%LED bulb%"))
        ).all()
        
        for item in items:
            print(f"Item: {item.name} (ID: {item.id})")
            print(f"  Is Asset Fixed: {item.is_asset_fixed}")
            print(f"  Category: {item.category.name if item.category else 'N/A'}")
            print(f"  Selling Price: {item.selling_price}")
            print(f"  Unit Price: {item.unit_price}")
            print(f"  Complimentary Limit: {item.complimentary_limit}")
            print("-" * 20)
            
    finally:
        db.close()

if __name__ == "__main__":
    check_items()
