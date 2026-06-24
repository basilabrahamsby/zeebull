import asyncio
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.checkout import Checkout

def read_db():
    db = SessionLocal()
    try:
        checkouts = db.query(Checkout).filter(Checkout.room_number == "201").order_by(Checkout.created_at.desc()).limit(3).all()
        for idx, c in enumerate(checkouts):
            print(f"[{idx}] Checkout ID: {c.id}, Room: {c.room_number}, Created: {c.created_at}")
            print(f"     Room Total: {c.room_total}, Food: {c.food_total}, Srv: {c.service_total}, Pkg: {c.package_total}")
            print(f"     Tax: {c.tax_amount}, Discount: {c.discount_amount}, Grand Total: {c.grand_total}")
            print("---")
    finally:
        db.close()

if __name__ == "__main__":
    read_db()
