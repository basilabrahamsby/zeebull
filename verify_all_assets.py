
from app.database import SessionLocal
from app.models.inventory import InventoryItem, InventoryCategory

def verify_all_assets():
    db = SessionLocal()
    try:
        print("\n--- ITEM ASSET STATUS VERIFICATION ---")
        items = db.query(InventoryItem).all()
        categories = {c.id: c for c in db.query(InventoryCategory).all()}
        
        for item in items:
            cat = categories.get(item.category_id)
            cat_name = cat.name if cat else "Unknown"
            cat_fixed = cat.is_asset_fixed if cat else False
            
            status = "✅ OK" if (cat_fixed and item.is_asset_fixed) or (not cat_fixed and not item.is_asset_fixed) else "❌ MISMATCH"
            if cat_fixed and not item.is_asset_fixed:
                status = "❌ CATEGORY IS FIXED ASSET BUT ITEM IS NOT"
            elif not cat_fixed and item.is_asset_fixed:
                status = "⚠️ ITEM IS FIXED ASSET BUT CATEGORY IS NOT (Allowed)"

            print(f"Item: {item.name:<20} | Category: {cat_name:<15} (Fixed: {cat_fixed}) | Item Fixed: {item.is_asset_fixed} | {status}")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    verify_all_assets()
