from app.database import SessionLocal
from app.models.inventory import Location

db = SessionLocal()
try:
    locs = db.query(Location).all()
    print(f"Total locations: {len(locs)}")
    for l in locs:
        print(f"ID: {l.id}, Name: {l.name}, Type: {l.location_type}, Active: {l.is_active}, Branch ID: {l.branch_id}")
finally:
    db.close()
