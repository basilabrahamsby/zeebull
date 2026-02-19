
import sys
import os
import json
from datetime import date, datetime

def default_json(obj):
    if isinstance(obj, (date, datetime)):
        return obj.isoformat()
    return str(obj)

current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.service_request import ServiceRequest
from sqlalchemy import desc

db = SessionLocal()

print("--- LATEST SERVICE REQUESTS ---")
reqs = db.query(ServiceRequest).order_by(desc(ServiceRequest.id)).limit(10).all()
for r in reqs:
    print(f"ID: {r.id}, Type: {r.request_type}, Status: {r.status}, Data: {r.refill_data}")

db.close()
