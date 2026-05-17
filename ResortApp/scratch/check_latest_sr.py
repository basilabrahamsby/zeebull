import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.service_request import ServiceRequest

db = SessionLocal()
try:
    print("--- LATEST SERVICE REQUESTS ---")
    requests = db.query(ServiceRequest).order_by(ServiceRequest.id.desc()).limit(3).all()
    for req in requests:
        print(f"ID: {req.id}")
        for col in req.__table__.columns.keys():
            print(f"  {col}: {getattr(req, col)}")
        print()
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
