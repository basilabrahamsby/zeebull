import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, item_id, transaction_type, quantity, total_amount, reference_number FROM inventory_transactions WHERE reference_number LIKE 'SVC-USAGE-13%'"))
    rows = res.fetchall()
    print("Found usage txns:", [dict(r._mapping) for r in rows])
