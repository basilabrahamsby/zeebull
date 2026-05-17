import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.checkout import CheckoutRequest

db = SessionLocal()
try:
    print("--- ALL CHECKOUT REQUESTS ---")
    reqs = db.query(CheckoutRequest).all()
    for r in reqs:
        print(f"ID: {r.id}, Room: {r.room_number}, Status: {r.status}, Guest: {r.guest_name}")
except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
