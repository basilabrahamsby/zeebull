from app.database import SessionLocal
from app.models.inventory import InventoryTransaction

db = SessionLocal()
try:
    t = db.query(InventoryTransaction).filter(InventoryTransaction.id == 256).first()
    if t:
        print(f"Transaction ID 256 Branch ID: {t.branch_id}")
    else:
        print("Not found!")
finally:
    db.close()
