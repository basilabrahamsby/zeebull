from app.database import SessionLocal
from app.models.inventory import Location

db = SessionLocal()
try:
    l = db.query(Location).filter(Location.id == 8).first()
    if l:
        print(f"Location ID 8: Name: {l.name}, Type: {l.location_type}, Active: {l.is_active}, Branch ID: {l.branch_id}")
    else:
        print("Location ID 8 not found!")
finally:
    db.close()
