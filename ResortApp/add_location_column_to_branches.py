import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from pathlib import Path

# Load environment variables
env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=env_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("Error: DATABASE_URL not found in .env")
    sys.exit(1)

print(f"Connecting to: {DATABASE_URL}")
engine = create_engine(DATABASE_URL)

with engine.connect() as conn:
    # Check existing columns
    result = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name = 'branches'"))
    existing_columns = [row[0] for row in result]
    print(f"Existing columns: {existing_columns}")

    if "location" not in existing_columns:
        print("Adding column location...")
        try:
            conn.execute(text("ALTER TABLE branches ADD COLUMN location VARCHAR"))
            conn.commit()
            print("Column location added successfully.")
        except Exception as e:
            print(f"Error adding column location: {e}")
    else:
        print("Column location already exists.")

print("Migration complete.")
