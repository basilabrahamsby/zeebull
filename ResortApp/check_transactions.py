from sqlalchemy import create_engine, text
import json
import os
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, transaction_type, quantity, description FROM inventory_transactions WHERE item_id = 20"))
    rows = res.fetchall()
    print(json.dumps([dict(r._mapping) for r in rows], default=str, indent=2))
