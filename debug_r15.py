
import sys
import os
import json
current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.service_request import ServiceRequest

db = SessionLocal()
r15 = db.query(ServiceRequest).filter(ServiceRequest.id == 15).first()
if r15:
    print(f"ID: {r15.id}")
    print(f"Status: {r15.status}")
    print(f"Refill Data: {r15.refill_data}")
    print(f"Pickup Location ID: {r15.pickup_location_id}")
else:
    print("Request 15 not found")
db.close()
