import sys
sys.path.append('/var/www/zeebull/ResortApp')
from app.database import SessionLocal
from app.models.inventory import LocationStock, InventoryItem, InventoryTransaction, PurchaseMaster, PurchaseDetail
db = SessionLocal()

try:
    print("--- Clearing All Inventory Stocks and Transactions ---")
    
    # 1. Update all LocationStock to 0.0
    updated_stocks = db.query(LocationStock).update({LocationStock.quantity: 0.0}, synchronize_session=False)
    print(f"Updated {updated_stocks} LocationStock records to 0.0")
    
    # 2. Update all InventoryItem current_stock to 0.0
    updated_items = db.query(InventoryItem).update({InventoryItem.current_stock: 0.0}, synchronize_session=False)
    print(f"Updated {updated_items} InventoryItem current_stock to 0.0")
    
    # 3. Delete all InventoryTransactions to ensure clean ledger history
    deleted_txns = db.query(InventoryTransaction).delete(synchronize_session=False)
    print(f"Deleted {deleted_txns} InventoryTransaction records")
    
    # 4. Delete all Purchases (Master + Detail) just in case
    deleted_details = db.query(PurchaseDetail).delete(synchronize_session=False)
    deleted_purchases = db.query(PurchaseMaster).delete(synchronize_session=False)
    print(f"Deleted {deleted_details} PurchaseDetail and {deleted_purchases} PurchaseMaster records")

    db.commit()
    print("✅ All stock levels and history cleared successfully!")
except Exception as e:
    db.rollback()
    print(f"Error during clearing: {e}")
finally:
    db.close()
