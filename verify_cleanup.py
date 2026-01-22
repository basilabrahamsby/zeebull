
import sys
import os

# Add the app directory to sys.path
sys.path.append('/var/www/inventory/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

def verify_empty():
    db = SessionLocal()
    try:
        checks = ["users", "rooms", "bookings", "stock_issues", "inventory_transactions", "activity_logs"]
        print("--- Verification Counts ---")
        for table in checks:
            count = db.execute(text(f'SELECT COUNT(*) FROM "{table}"')).scalar()
            print(f"{table}: {count}")
    finally:
        db.close()

if __name__ == "__main__":
    verify_empty()
