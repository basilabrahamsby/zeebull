from sqlalchemy import create_engine, text
import json
import os
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, name, category_id, current_stock FROM inventory_items WHERE name ILIKE '%floor%'"))
    rows = res.fetchall()
    print(json.dumps([{"id": r[0], "name": r[1], "category_id": r[2], "current_stock": r[3]} for r in rows], indent=2))
