import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, status, quantity_assigned, quantity_used, quantity_returned FROM employee_inventory_assignments WHERE assigned_service_id = 15"))
    rows = res.fetchall()
    print("Emp Inv Assign 15:", [dict(r._mapping) for r in rows])
