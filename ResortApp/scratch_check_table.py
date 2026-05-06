import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.calendar import PricingCalendar

db = SessionLocal()
try:
    events = db.query(PricingCalendar).all()
    print(f"Table exists! Found {len(events)} events.")
except Exception as e:
    print(f"Error querying table: {e}")
finally:
    db.close()
