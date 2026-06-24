import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, status, quantity_assigned, quantity_used, quantity_returned FROM employee_inventory_assignments ORDER BY id DESC LIMIT 5"))
    rows = res.fetchall()
    for r in rows:
        print(dict(r._mapping))
