
import sys
import os
import json

current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.inventory import Location

db = SessionLocal()
locs = db.query(Location).filter(Location.is_active == True).all()
result = []
for l in locs:
    result.append({
        "id": l.id,
        "name": l.name,
        "type": l.location_type
    })

print(json.dumps(result, indent=2))
db.close()
