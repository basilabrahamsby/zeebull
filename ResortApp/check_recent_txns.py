import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, status FROM assigned_services ORDER BY id DESC LIMIT 2"))
    rows = res.fetchall()
    print("Assigned Services:", [dict(r._mapping) for r in rows])
    
    res = conn.execute(text("SELECT id, item_id, transaction_type, quantity, total_amount, reference_number FROM inventory_transactions ORDER BY id DESC LIMIT 5"))
    rows = res.fetchall()
    print("Recent Txns:", [dict(r._mapping) for r in rows])
    
    res = conn.execute(text("SELECT id, journal_type, total_amount, reference_number, notes FROM account_journal_entries ORDER BY id DESC LIMIT 5"))
    rows = res.fetchall()
    print("Recent Journals:", [dict(r._mapping) for r in rows])
