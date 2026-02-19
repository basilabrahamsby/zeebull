from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.inventory import WasteLog, InventoryTransaction, LocationStock, InventoryItem, AssetRegistry
from sqlalchemy import or_

def inspect_waste():
    db = SessionLocal()
    try:
        waste_logs = db.query(WasteLog).filter(WasteLog.log_number.in_(['WASTE-20260219-001', 'WASTE-20260219-002'])).all()
        print(f"Found {len(waste_logs)} WasteLog entries.")
        for log in waste_logs:
            print(f"Log: {log.log_number}, Item ID: {log.item_id}, Qty: {log.quantity}, Location: {log.location_id}")
            
        txns = db.query(InventoryTransaction).filter(InventoryTransaction.reference_number.in_(['WASTE-20260219-001', 'WASTE-20260219-002'])).all()
        print(f"Found {len(txns)} InventoryTransaction entries.")
        for txn in txns:
            print(f"Txn: {txn.reference_number}, Item: {txn.item_id}, Qty: {txn.quantity}, Type: {txn.transaction_type}")
            
    finally:
        db.close()

if __name__ == "__main__":
    inspect_waste()
