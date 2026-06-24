import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT key, value FROM system_settings WHERE key LIKE '%gst%'"))
    rows = res.fetchall()
    print("GST Settings:", [dict(r._mapping) for r in rows])
