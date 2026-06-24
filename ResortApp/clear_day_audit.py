from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)

with engine.connect() as conn:
    # Check if the record exists
    res = conn.execute(text("SELECT id, business_date, status FROM day_audits WHERE business_date = '2026-06-24'"))
    row = res.fetchone()
    if row:
        print(f"Found audit record: {dict(row._mapping)}")
        # Delete it
        conn.execute(text("DELETE FROM day_audits WHERE business_date = '2026-06-24'"))
        conn.commit()
        print("Successfully deleted the audit record for 2026-06-24.")
    else:
        print("No audit record found for 2026-06-24.")
