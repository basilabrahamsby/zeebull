
from app.database import SessionLocal
from app.models.inventory import InventoryItem

db = SessionLocal()
try:
    # 1. Update Tv and Bulb to be non-perishable
    items_to_fix = ["Tv", "Bulb"]
    
    print(f"Fixing perishable status for: {items_to_fix}")
    
    for name in items_to_fix:
        # ILIKE for case-insensitive match
        items = db.query(InventoryItem).filter(InventoryItem.name.ilike(f"%{name}%")).all()
        for item in items:
            if item.is_perishable:
                print(f"Update: Setting {item.name} (ID: {item.id}) is_perishable = False")
                item.is_perishable = False
            else:
                print(f"Skipping: {item.name} is already non-perishable")
                
    db.commit()
    print("Database update complete.")

except Exception as e:
    print(f"Error during update: {e}")
    db.rollback()
finally:
    db.close()
