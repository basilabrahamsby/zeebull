from app.database import SessionLocal
from app.models.inventory import InventoryTransaction, InventoryItem

db = SessionLocal()
try:
    txns = db.query(InventoryTransaction).join(InventoryItem).order_by(InventoryTransaction.id.desc()).limit(20).all()
    print(f"Total transactions fetched: {len(txns)}")
    for t in txns:
        print(f"ID: {t.id}, Item: {t.item.name}, Type: {t.transaction_type}, Qty: {t.quantity}, Price: {t.unit_price}, Ref: {t.reference_number}, Notes: {t.notes}, Created: {t.created_at}")
finally:
    db.close()
