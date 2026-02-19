
import sys
import os
current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.inventory import Location

db = SessionLocal()

print("--- LOCATIONS ---")
locs = db.query(Location).filter(Location.location_type.in_(['WAREHOUSE', 'STORE', 'SHOP'])).all()
for l in locs:
    print(f"ID: {l.id}, Name: {l.name}, Type: {l.location_type}")

db.close()
