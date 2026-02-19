from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.inventory import WasteLog, InventoryTransaction, LocationStock, InventoryItem, AssetRegistry
from datetime import datetime
from sqlalchemy import func

def inspect_today():
    db = SessionLocal()
    try:
        today = datetime.utcnow().date()
        txns = db.query(InventoryTransaction).filter(func.date(InventoryTransaction.created_at) == today).all()
        print(f"Found {len(txns)} transactions today.")
        for txn in txns:
            print(f"ID: {txn.id}, Ref: {txn.reference_number}, Item: {txn.item_id}, Qty: {txn.quantity}, Type: {txn.transaction_type}, Notes: {txn.notes}")
            
        waste = db.query(WasteLog).all()
        print(f"Total WasteLogs: {len(waste)}")
        for w in waste:
             print(f"Log: {w.log_number}, Item: {w.item_id}, Date: {w.waste_date}")
            
    finally:
        db.close()

if __name__ == "__main__":
    inspect_today()
