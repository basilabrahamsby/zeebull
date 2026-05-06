import sys
import os

# Add the current directory to sys.path to import app modules
sys.path.append(os.getcwd())

from app.database import engine, SessionLocal
from sqlalchemy import text

def migrate():
    print("Starting migration to add confirmation fields...")
    
    commands = [
        # For bookings table
        "ALTER TABLE bookings ADD COLUMN IF NOT EXISTS is_confirmed BOOLEAN DEFAULT FALSE;",
        "ALTER TABLE bookings ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITHOUT TIME ZONE;",
        "ALTER TABLE bookings ADD COLUMN IF NOT EXISTS confirmation_notes TEXT;",
        
        # For package_bookings table
        "ALTER TABLE package_bookings ADD COLUMN IF NOT EXISTS is_confirmed BOOLEAN DEFAULT FALSE;",
        "ALTER TABLE package_bookings ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMP WITHOUT TIME ZONE;",
        "ALTER TABLE package_bookings ADD COLUMN IF NOT EXISTS confirmation_notes TEXT;",
    ]
    
    db = SessionLocal()
    try:
        for cmd in commands:
            print(f"Executing: {cmd}")
            db.execute(text(cmd))
        db.commit()
        print("Migration completed successfully!")
    except Exception as e:
        print(f"Error during migration: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    migrate()
