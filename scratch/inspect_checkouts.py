import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from pathlib import Path

env_path = Path(__file__).parent.parent / "ResortApp" / ".env"
load_dotenv(dotenv_path=env_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("Error: DATABASE_URL not found in .env")
    sys.exit(1)

print(f"Connecting to: {DATABASE_URL}")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    # Get columns of checkouts
    result = conn.execute(text("""
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = 'checkouts'
    """)).fetchall()
    
    print("\n--- Checkouts Columns ---")
    for col in result:
        print(f"{col[0]}: {col[1]}")
