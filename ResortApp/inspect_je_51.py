from app.database import SessionLocal
from app.models.account import JournalEntry, JournalEntryLine
from sqlalchemy.orm import joinedload

db = SessionLocal()
try:
    tx = db.query(JournalEntry).options(
        joinedload(JournalEntry.lines).joinedload(JournalEntryLine.debit_ledger),
        joinedload(JournalEntry.lines).joinedload(JournalEntryLine.credit_ledger)
    ).filter(JournalEntry.entry_number == "JE-2026-05-0022").first()
    
    if tx:
        print(f"Entry: {tx.entry_number}, Description: {tx.description}, Amount: {tx.total_amount}")
        for line in tx.lines:
            debit_name = line.debit_ledger.name if line.debit_ledger else "None"
            credit_name = line.credit_ledger.name if line.credit_ledger else "None"
            print(f"  Line: Debit={debit_name}, Credit={credit_name}, Amount={line.amount}")
    else:
        print("Transaction not found")
finally:
    db.close()
