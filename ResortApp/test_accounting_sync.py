from app.database import SessionLocal
from app.utils.accounting_helpers import create_advance_payment_journal_entry
from app.models.account import JournalEntry, JournalEntryLine
from sqlalchemy.orm import joinedload
import uuid

def test_bank_transfer_mapping():
    print("Testing Bank Transfer Mapping...")
    db = SessionLocal()
    try:
        # Create a dummy booking ID or use an existing one
        booking_id = 9999
        amount = 1234.56
        payment_method = "bank_transfer" # This is the underscore version from DB
        guest_name = "Test Guest"
        branch_id = 1
        
        # Call the helper
        je_id = create_advance_payment_journal_entry(
            db=db,
            booking_id=booking_id,
            amount=amount,
            payment_method=payment_method,
            guest_name=guest_name,
            branch_id=branch_id
        )
        
        if not je_id:
            print("FAILED: Journal entry was not created.")
            return

        # Fetch and verify
        je = db.query(JournalEntry).options(
            joinedload(JournalEntry.lines).joinedload(JournalEntryLine.debit_ledger)
        ).filter(JournalEntry.id == je_id).first()
        
        debit_ledger_name = je.lines[0].debit_ledger.name if je.lines[0].debit_ledger else "None"
        print(f"Journal Entry Created: {je.entry_number}")
        print(f"Debit Ledger Used: {debit_ledger_name}")
        
        if debit_ledger_name == "Bank Account - Main":
            print("SUCCESS: Correctly mapped to Bank Account - Main!")
        else:
            print(f"FAILED: Mapped to {debit_ledger_name} instead of Bank Account - Main.")
            
    finally:
        db.close()

if __name__ == "__main__":
    test_bank_transfer_mapping()
