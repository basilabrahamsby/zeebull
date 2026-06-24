import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    res = conn.execute(text("SELECT id, entry_number, reference_type, total_amount, description FROM journal_entries ORDER BY id DESC LIMIT 5"))
    rows = res.fetchall()
    print("Recent Journals:", [dict(r._mapping) for r in rows])
