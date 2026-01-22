
from app.database import SessionLocal
from app.models.inventory import InventoryItem, Category

db = SessionLocal()
items = db.query(InventoryItem).filter(InventoryItem.name.like("%Kettle%")).all()
for item in items:
    cat = db.query(Category).filter(Category.id == item.category_id).first()
    print(f"Item: {item.name}, Fixed: {item.is_asset_fixed}, Cat: {cat.name if cat else 'None'}, CatFixed: {cat.is_asset_fixed if cat else 'None'}")
