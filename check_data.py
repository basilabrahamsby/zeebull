import sys
import os
sys.path.append('/home/basilabrahamaby/resort_app')
from app.core.database import SessionLocal
from app.models.checkout import Checkout
from sqlalchemy import func

def check_data():
    try:
        db = SessionLocal()
        count = db.query(Checkout).count()
        print(f"Total Checkouts: {count}")
        
        if count > 0:
            # Check for non-zero room_total (used in master summary filter)
            valid_summary_count = db.query(Checkout).filter(Checkout.room_total > 0).count()
            print(f"Checkouts with room_total > 0: {valid_summary_count}")
            
            # Check sum
            total_sales = db.query(func.sum(Checkout.grand_total)).scalar() or 0
            print(f"Total Sales Volume: {total_sales}")
            
    except Exception as e:
        print(f"Error querying database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_data()
