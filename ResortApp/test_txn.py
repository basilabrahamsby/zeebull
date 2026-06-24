import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Try to run the exact code that creates the transaction to see if it throws!
db = SessionLocal()
try:
    from app.models.inventory import InventoryItem, InventoryTransaction, LocationStock
    from app.models.service import AssignedService
    from datetime import timezone, datetime
    
    assigned_id = 13
    quantity_used = 0.1
    updated_by = 1
    
    assigned = db.query(AssignedService).filter(AssignedService.id == assigned_id).first()
    item = db.query(InventoryItem).filter(InventoryItem.id == 20).first()
    
    consumption_amount = quantity_used * (item.unit_price or 0.0)
    
    inv_txn = InventoryTransaction(
        item_id=item.id, transaction_type="out", quantity=quantity_used,
        unit_price=item.unit_price, total_amount=consumption_amount,
        reference_number=f"SVC-USAGE-{assigned_id}",
        department=item.category.name if item.category else "Housekeeping",
        notes=f"Actual Consumption during Service: {assigned.service.name}",
        created_by=updated_by, branch_id=assigned.branch_id, created_at=datetime.now(timezone.utc),
        source_location_id=assigned.room.inventory_location_id if assigned.room else None
    )
    db.add(inv_txn)
    db.flush()
    print("Flush succeeded, txn ID:", inv_txn.id)
    
    if consumption_amount > 0:
        from app.utils.accounting_helpers import create_consumption_journal_entry
        dept_name = item.category.name if item.category else "Housekeeping"
        debit_ledger = f"{dept_name} Supplies" if dept_name.lower() == "housekeeping" else dept_name
        
        try:
            je_id = create_consumption_journal_entry(
                db=db,
                consumption_id=inv_txn.id,
                cogs_amount=consumption_amount,
                inventory_item_name=item.name,
                branch_id=assigned.branch_id,
                created_by=updated_by,
                reference_type="inventory_consumption",
                debit_ledger_name=debit_ledger
            )
            print("Journal Entry ID:", je_id)
        except Exception as je_err:
            print(f"[WARNING] Failed to create consumption journal entry: {je_err}")
            
    db.rollback()
except Exception as e:
    import traceback
    traceback.print_exc()
finally:
    db.close()
