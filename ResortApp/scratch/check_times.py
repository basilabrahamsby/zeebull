import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.service_request import ServiceRequest
from app.models.foodorder import FoodOrder

db = SessionLocal()
try:
    print("--- LATEST SERVICE REQUESTS ---")
    requests = db.query(ServiceRequest).order_by(ServiceRequest.id.desc()).limit(5).all()
    for req in requests:
        print(f"ID: {req.id}")
        for col in req.__table__.columns.keys():
            print(f"  {col}: {getattr(req, col)}")
        print()

    print("\n--- LATEST FOOD ORDERS ---")
    orders = db.query(FoodOrder).order_by(FoodOrder.id.desc()).limit(5).all()
    for ord in orders:
        print(f"ID: {ord.id}")
        for col in ord.__table__.columns.keys():
            print(f"  {col}: {getattr(ord, col)}")
        print()

except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
