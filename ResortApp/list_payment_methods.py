from app.database import SessionLocal
from app.models.payment import Payment
from sqlalchemy import func

db = SessionLocal()
try:
    methods = db.query(Payment.method, func.count(Payment.id)).group_by(Payment.method).all()
    print("Unique Payment Methods in DB:")
    for method, count in methods:
        print(f"  - '{method}': {count} occurrences")
finally:
    db.close()
