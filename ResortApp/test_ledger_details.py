from app.database import SessionLocal
from app.models.account import AccountLedger, JournalEntry, JournalEntryLine
from sqlalchemy.orm import joinedload
from sqlalchemy import or_

db = SessionLocal()
ledger = db.query(AccountLedger).filter(AccountLedger.name == 'Furniture & Fixtures').first()

if ledger:
    lines = db.query(JournalEntryLine).join(JournalEntry).filter(
        or_(
            JournalEntryLine.debit_ledger_id == ledger.id,
            JournalEntryLine.credit_ledger_id == ledger.id
        )
    ).all()
    
    details_map = {}
    
    for line in lines:
        je = line.entry
        # amount calculation
        is_debit = line.debit_ledger_id == ledger.id
        amt = line.amount if is_debit else -line.amount
        
        detail_name = line.description or je.description or f"JE {je.entry_number}"
        
        if je.reference_type == 'purchase':
            from app.models.inventory import PurchaseMaster, PurchaseDetail, InventoryItem
            pm = db.query(PurchaseMaster).get(je.reference_id)
            if pm:
                for pd in pm.details:
                    item = db.query(InventoryItem).get(pd.item_id)
                    name = item.name if item else "Unknown Item"
                    if name not in details_map:
                        details_map[name] = 0.0
                    details_map[name] += float(pd.total_amount if is_debit else -pd.total_amount)
                continue
                
        if detail_name not in details_map:
            details_map[detail_name] = 0.0
        details_map[detail_name] += float(amt)

    print("Details for", ledger.name)
    for name, amt in details_map.items():
        print(f"  {name}: {amt}")

