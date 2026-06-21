from app.database import SessionLocal
from app.models.inventory import InventoryTransaction, InventoryItem
from app.models.account import JournalEntry
from app.utils.accounting_helpers import create_consumption_journal_entry

db = SessionLocal()
txns = db.query(InventoryTransaction).filter(
    InventoryTransaction.transaction_type == 'out',
    InventoryTransaction.reference_number.like('SVC-USAGE-%')
).all()

count = 0
for txn in txns:
    je = db.query(JournalEntry).filter(
        JournalEntry.reference_type == 'inventory_consumption',
        JournalEntry.reference_id == txn.id
    ).first()
    
    if not je:
        item = db.query(InventoryItem).get(txn.item_id)
        dept_name = item.category.name if item.category else 'Housekeeping'
        debit_ledger = f'{dept_name} Supplies' if dept_name.lower() == 'housekeeping' else dept_name
        
        try:
            create_consumption_journal_entry(
                db=db,
                consumption_id=txn.id,
                cogs_amount=float(txn.total_amount or 0),
                inventory_item_name=item.name,
                branch_id=txn.branch_id,
                created_by=txn.created_by,
                reference_type='inventory_consumption',
                debit_ledger_name=debit_ledger
            )
            count += 1
        except Exception as e:
            print(f'Error on txn {txn.id}: {e}')

db.commit()
print(f'Created {count} missing consumption journal entries.')
