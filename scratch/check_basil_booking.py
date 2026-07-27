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
    # Get all column names of bookings
    cols = [c[0] for c in conn.execute(text("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name='bookings'
        ORDER BY ordinal_position
    """)).fetchall()]
    
    # Get row 96
    row = conn.execute(text("SELECT * FROM bookings WHERE id = 96")).fetchone()
    
    print("\n--- Columns and Values for Booking 96 ---")
    for col, val in zip(cols, row):
        print(f"  {col}: {val}")
