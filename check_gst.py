
import os
import sys

# Force UTF-8 output
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

# Add the project root to sys.path
sys.path.append(os.path.join(os.getcwd(), "ResortApp"))

from app.database import SessionLocal
from app.models.inventory import InventoryItem

def check_gst():
    db = SessionLocal()
    try:
        item = db.query(InventoryItem).filter(InventoryItem.name.ilike("%LED bulb%")).first()
        if item:
            print(f"Item: {item.name}")
            print(f"  Unit Price: {item.unit_price}")
            print(f"  GST Rate: {item.gst_rate}")
    finally:
        db.close()

if __name__ == "__main__":
    check_gst()
