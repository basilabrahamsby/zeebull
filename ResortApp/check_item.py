import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, name, track_laundry_cycle, category_id FROM inventory_items WHERE id = 20"))
    print("Item 20:", dict(res.fetchone()._mapping))
    
    res = conn.execute(text("SELECT id, name, track_laundry FROM inventory_categories WHERE id = (SELECT category_id FROM inventory_items WHERE id = 20)"))
    row = res.fetchone()
    if row:
        print("Category:", dict(row._mapping))
    else:
        print("No category")
