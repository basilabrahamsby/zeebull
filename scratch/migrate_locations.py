import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

db = SessionLocal()

try:
    print("Executing migration SQL...")
    # Add columns to employees table
    db.execute(text("ALTER TABLE employees ADD COLUMN IF NOT EXISTS latitude FLOAT;"))
    db.execute(text("ALTER TABLE employees ADD COLUMN IF NOT EXISTS longitude FLOAT;"))
    db.execute(text("ALTER TABLE employees ADD COLUMN IF NOT EXISTS last_location_update TIMESTAMP;"))
    
    # Create employee_location_history table
    db.execute(text("""
    CREATE TABLE IF NOT EXISTS employee_location_history (
        id SERIAL PRIMARY KEY,
        employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
        latitude FLOAT NOT NULL,
        longitude FLOAT NOT NULL,
        timestamp TIMESTAMP NOT NULL
    );
    """))
    db.commit()
    print("Database migration completed successfully!")
except Exception as e:
    db.rollback()
    print(f"Error during migration: {e}")
finally:
    db.close()
