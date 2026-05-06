from dotenv import load_dotenv
import os
from pathlib import Path

# Load .env explicitly
env_path = Path(".env")
load_dotenv(dotenv_path=env_path)

from app.database import SessionLocal
from app.core.aiosell_triggers import trigger_rates_push
from app.core.aiosell_client import HOTEL_CODE, PARTNER_ID
import logging

# Set up logging to console to see the output
logging.basicConfig(level=logging.INFO)

print(f"DEBUG: HOTEL_CODE={HOTEL_CODE}, PARTNER_ID={PARTNER_ID}")

db = SessionLocal()
try:
    print("Attempting manual sync for room type 3...")
    trigger_rates_push(3, days=30)
    
    print("\nAttempting manual sync for room type 5...")
    trigger_rates_push(5, days=30)
    
finally:
    db.close()
