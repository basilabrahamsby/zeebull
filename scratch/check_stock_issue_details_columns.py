import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from pathlib import Path

# Load env from ResortApp/.env
env_path = Path(__file__).parent.parent / "ResortApp" / ".env"
load_dotenv(dotenv_path=env_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("Error: DATABASE_URL not found in .env")
    sys.exit(1)

print(f"Connecting to: {DATABASE_URL}")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    cols = ["is_payable", "is_paid", "rental_price", "is_damaged", "damage_notes"]
    for col in cols:
        result = conn.execute(text(f"""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='stock_issue_details' AND column_name='{col}'
        """)).fetchone()
        
        if result:
            print(f"Column '{col}' ALREADY EXISTS in 'stock_issue_details'.")
        else:
            print(f"Column '{col}' is MISSING in 'stock_issue_details'!")
