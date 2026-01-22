import sys
import os

# Add the project root to sys.path
sys.path.append("/var/www/inventory/ResortApp")

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import SQLALCHEMY_DATABASE_URL
from app.curd.inventory import update_purchase_status, get_purchase_by_id

# Setup DB session
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

PO_NUMBER = "PO-20260117-0001"

def repair():
    from app.models.inventory import PurchaseMaster
    purchase = db.query(PurchaseMaster).filter(PurchaseMaster.purchase_number == PO_NUMBER).first()
    
    if not purchase:
        print(f"Purchase {PO_NUMBER} not found")
        return
    
    print(f"Found purchase {purchase.id} ({purchase.purchase_number}) with status {purchase.status}")
    
    # Reset status to draft to trigger the 'received' logic again if it's already received
    if purchase.status.lower() == "received":
        purchase.status = "draft"
        db.commit()
        print("Temporarily reset status to draft to trigger update logic")
    
    # Call the newly fixed update_purchase_status
    updated = update_purchase_status(db, purchase.id, "received")
    
    if updated:
        print(f"Successfully repaired purchase {PO_NUMBER}")
        print("New status:", updated.status)
    else:
        print(f"Failed to repair purchase {PO_NUMBER}")

if __name__ == "__main__":
    try:
        repair()
    except Exception as e:
        import traceback
        print(f"Error: {e}")
        traceback.print_exc()
    finally:
        db.close()
