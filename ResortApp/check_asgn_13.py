import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, status FROM assigned_services WHERE id = 13"))
    print("Assigned Service 13:", res.fetchone())
    
    res = conn.execute(text("SELECT id, assigned_service_id, status, quantity_used FROM employee_inventory_assignments WHERE assigned_service_id = 13"))
    print("Emp Inv Assign 13:", res.fetchone())
