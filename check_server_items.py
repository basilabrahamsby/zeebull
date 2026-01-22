import sys
import os

# Add the project root to sys.path
sys.path.append("/var/www/inventory/ResortApp")

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import SQLALCHEMY_DATABASE_URL
from app.models.inventory import InventoryItem

# Setup DB session
engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
db = SessionLocal()

def check_items():
    codes = ['INV0992', 'HIJ588', 'INV73736', 'INV09029']
    items = db.query(InventoryItem).filter(InventoryItem.item_code.in_(codes)).all()
    
    if not items:
        print("No items found with those codes.")
        return
        
    for item in items:
        print(f"ID: {item.id} | Code: {item.item_code} | Name: '{item.name}' | Active: {item.is_active}")

if __name__ == "__main__":
    try:
        check_items()
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()
