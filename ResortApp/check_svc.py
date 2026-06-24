import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, service_id FROM assigned_services WHERE id = 13"))
    print("Assigned Service 13:", dict(res.fetchone()._mapping))
    
    res = conn.execute(text("SELECT id, name FROM services WHERE id = (SELECT service_id FROM assigned_services WHERE id = 13)"))
    print("Service:", dict(res.fetchone()._mapping))
