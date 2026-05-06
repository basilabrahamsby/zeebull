from app.database import SessionLocal
from app.models.room import RoomType, RatePlan
from app.models.calendar import PricingCalendar
from datetime import date

db = SessionLocal()
try:
    print("--- Room Types and Pricing ---")
    room_types = db.query(RoomType).all()
    for rt in room_types:
        print(f"ID: {rt.id}, Name: {rt.name}, CM ID: {rt.channel_manager_id}")
        print(f"  Base: {rt.base_price}, Weekend: {rt.weekend_price}, Holiday: {rt.holiday_price}")
    
    print("\n--- Pricing Calendar Overrides ---")
    today = date.today()
    overrides = db.query(PricingCalendar).filter(PricingCalendar.end_date >= today).all()
    if not overrides:
        print("No future overrides found in PricingCalendar.")
    for ov in overrides:
        print(f"ID: {ov.id}, Type: {ov.day_type}, Start: {ov.start_date}, End: {ov.end_date}")

finally:
    db.close()
