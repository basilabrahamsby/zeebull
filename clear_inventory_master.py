
import sys
import os

# Add the app directory to sys.path
sys.path.append('/var/www/inventory/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

TABLES_TO_WIPE = [
    # Core Inventory
    "inventory_categories",
    "inventory_items",
    
    # Food & Beverage
    "food_categories",
    "food_items",
    "recipes",
    "recipe_ingredients",
    
    # Locations
    "locations",
    "outlets",
    
    # Relations
    "vendor_items",
    "room_consumable_items",
    "service_inventory_items",
    "room_assets"
]

def clear_inventory_master():
    db = SessionLocal()
    try:
        print("=== CLEARING INVENTORY MASTER DATA ===")
        print("(Items, Categories, Locations, and connections)")
        
        for table in TABLES_TO_WIPE:
            print(f"  - Truncating '{table}' with CASCADE...")
            try:
                db.execute(text(f'TRUNCATE TABLE "{table}" RESTART IDENTITY CASCADE'))
            except Exception as e:
                 # Ignore if table doesn't exist (e.g. some relation tables)
                if "does not exist" not in str(e):
                    print(f"    Warning: {e}")
                else:
                    print(f"    (Table {table} not found, skipping)")
        
        db.commit()
        print("\n=== SUCCESS: MASTER DATA CLEARED ===")
        
    except Exception as e:
        db.rollback()
        print(f"\n[ERROR] Failed to clear data: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    clear_inventory_master()
