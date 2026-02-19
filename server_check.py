from app.database import SessionLocal
from app.models.inventory import WasteLog, InventoryTransaction, InventoryItem
from sqlalchemy import or_

def check():
    db = SessionLocal()
    try:
        log_numbers = ['WASTE-20260219-001', 'WASTE-20260219-002']
        logs = db.query(WasteLog).filter(WasteLog.log_number.in_(log_numbers)).all()
        print(f"Server WasteLogs: {[(l.log_number, l.item_id) for l in logs]}")
        
        txns = db.query(InventoryTransaction).filter(InventoryTransaction.reference_number.in_(log_numbers)).all()
        print(f"Server Transactions: {[(t.reference_number, t.item_id, t.quantity) for t in txns]}")
    finally:
        db.close()

if __name__ == "__main__":
    check()
