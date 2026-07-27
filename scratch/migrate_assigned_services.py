import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import engine
from sqlalchemy import text

with engine.connect() as conn:
    print("Adding location_id column to assigned_services...")
    try:
        conn.execute(text("ALTER TABLE assigned_services ADD COLUMN location_id INTEGER REFERENCES locations(id);"))
        conn.commit()
        print("Successfully added location_id column.")
    except Exception as e:
        print("Error/Already exists:", e)
