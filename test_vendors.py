from app.utils.auth import get_db
from app.models.inventory import Vendor, PurchaseMaster
from sqlalchemy import func

db = next(get_db())

print("=== Checking Vendors ===")
vendors = db.query(Vendor).all()
for v in vendors:
    print(f"Vendor: {v.name} (ID: {v.id})")

print("\n=== Checking Purchases ===")
purchases = db.query(PurchaseMaster).all()
for p in purchases:
    print(f"Purchase #{p.purchase_number}, Vendor ID: {p.vendor_id}, Amount: {p.total_amount}")
    if p.vendor:
        print(f"  -> Vendor: {p.vendor.name}")

print("\n=== Testing Vendor Stats Endpoint ===")
for v in vendors:
    purch_total = db.query(func.sum(PurchaseMaster.total_amount))\
        .filter(PurchaseMaster.vendor_id == v.id)\
        .scalar() or 0.0
    print(f"{v.name}: Total Purchases = ₹{purch_total}")
