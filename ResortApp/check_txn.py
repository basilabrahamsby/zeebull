import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, item_id, transaction_type, quantity, unit_price, total_amount, reference_number FROM inventory_transactions ORDER BY id DESC LIMIT 5"))
    rows = res.fetchall()
    for r in rows:
        print(dict(r._mapping))
