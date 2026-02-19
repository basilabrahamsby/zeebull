
from app.database import SessionLocal
from app.models.inventory import InventoryItem, InventoryCategory

db = SessionLocal()
try:
    items = ["Tv", "Bulb", "AC"]
    print(f"{'Item Name':<15} | {'Category':<20} | {'Is Perishable':<15} | {'Is Sellable':<15} | {'Active':<10}")
    print("-" * 80)
    
    for name in items:
        # ILIKE for case-insensitive match
        item = db.query(InventoryItem).filter(InventoryItem.name.ilike(f"%{name}%")).first()
        if item:
            cat_name = item.category.name if item.category else "None"
            print(f"{item.name:<15} | {cat_name:<20} | {str(item.is_perishable):<15} | {str(item.is_sellable_to_guest):<15} | {str(item.is_active):<10}")
        else:
            print(f"{name:<15} | {'Not Found':<20} | {'-':<15} | {'-':<15} | {'-':<10}")

finally:
    db.close()
