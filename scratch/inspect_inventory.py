import sys
sys.path.append('/var/www/zeebull/ResortApp')
from app.database import SessionLocal
from app.models.inventory import InventoryItem
db = SessionLocal()

active_count = db.query(InventoryItem).filter(InventoryItem.is_active == True).count()
inactive_count = db.query(InventoryItem).filter(InventoryItem.is_active == False).count()
print(f"Active items: {active_count}, Inactive items: {inactive_count}")

all_items = db.query(InventoryItem).all()
for i in all_items:
    print(f"ID: {i.id}, Name: {i.name}, Active: {i.is_active}")
