import os, sys

os.environ['DATABASE_URL'] = 'postgresql+psycopg2://postgres:qwerty123@localhost:5432/zeebuldb'
os.environ['AIOSELL_ACTIVE'] = 'true'
os.environ['AIOSELL_HOTEL_CODE'] = 'a0e3cff078'
os.environ['AIOSELL_PARTNER_ID'] = 'teqmates-hospitality'
os.environ['AIOSELL_API_URL'] = 'https://live.aiosell.com/api/v2/cm/update'
os.environ['AIOSELL_USERNAME'] = 'teqmates-hospitality'
os.environ['AIOSELL_PASSWORD'] = '1zdv6udu'

sys.path.insert(0, '/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.room import RoomType
from app.models.calendar import PricingCalendar

db = SessionLocal()

# Check room types with channel manager mapping
rts = db.query(RoomType).filter(
    RoomType.channel_manager_id.isnot(None),
    RoomType.channel_manager_id != ''
).all()
print(f"Room types with CM mapping: {len(rts)}")
for r in rts:
    print(f"  [{r.id}] {r.name} -> CM={r.channel_manager_id} | holiday={r.holiday_price}")

# Now trigger the rate push for each room type
if rts:
    print("\nTriggering Aiosell rate push with REAL credentials...")
    from app.core.aiosell_triggers import trigger_rates_push
    for rt in rts:
        print(f"\n  Pushing rates for: {rt.name} ({rt.channel_manager_id})")
        trigger_rates_push(rt.id, days=180)
        print(f"  Done.")
else:
    print("\nNo room types with CM mapping found!")

db.close()
print("\nComplete.")
