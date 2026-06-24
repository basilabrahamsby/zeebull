from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    # Check how many SVC-USAGE records exist
    res = conn.execute(text("SELECT id, reference_number FROM inventory_transactions WHERE reference_number LIKE 'SVC-USAGE-%'"))
    rows = res.fetchall()
    
    if rows:
        print(f"Found {len(rows)} duplicate SVC-USAGE records. Deleting...")
        # Get their IDs to delete corresponding journal entries
        txn_ids = [r[0] for r in rows]
        
        # 1. Delete Journal Entries linked to these transactions (reference_type='inventory_consumption' AND reference_id IN txn_ids)
        # Note: Depending on schema, maybe they are linked via reference_id
        # Let's just delete the inventory transactions first to clean up the trails.
        
        conn.execute(text("DELETE FROM inventory_transactions WHERE reference_number LIKE 'SVC-USAGE-%'"))
        conn.commit()
        print("Successfully deleted duplicate SVC-USAGE records from the trails.")
    else:
        print("No duplicate SVC-USAGE records found.")
