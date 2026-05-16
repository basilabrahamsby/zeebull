from app.database import SessionLocal
from app.models.payment import Payment

db = SessionLocal()
try:
    p = db.query(Payment).filter(Payment.amount == 6000).order_by(Payment.id.desc()).first()
    if p:
        print(f"Payment ID: {p.id}, Method: '{p.method}', Amount: {p.amount}")
    else:
        print("Payment not found")
finally:
    db.close()
