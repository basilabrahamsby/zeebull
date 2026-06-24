import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, service_id, room_id FROM assigned_services WHERE id IN (14, 15)"))
    rows = res.fetchall()
    print("Assigned Services:", [dict(r._mapping) for r in rows])
