
import sys
import os

# Add the app directory to sys.path
sys.path.append('/var/www/inventory/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

def clear_rooms():
    db = SessionLocal()
    try:
        print("=== CLEARING ALL ROOM DEFINITIONS ===")
        
        # We use CASCADE to ensure any dependent data (like room assets, images, or lingering booking links) is also removed.
        # This will DELETE the actual room records (Room 101, 102, etc.)
        print("  - Truncating 'rooms' table with CASCADE...")
        db.execute(text('TRUNCATE TABLE "rooms" RESTART IDENTITY CASCADE'))
        
        # Also clear room_assets if it exists, as it's dependent on rooms
        # (Cascade should handle it if FK exists, but explicit check doesn't hurt)
        # We'll rely on CASCADE for simplicity and thoroughness.
        
        db.commit()
        print("\n=== SUCCESS: ALL ROOMS DELETED ===")
        
    except Exception as e:
        db.rollback()
        print(f"\n[ERROR] Failed to clear rooms: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    clear_rooms()
