from app.database import SessionLocal
from app.api.booking import get_bookings
db=SessionLocal()
bookings=get_bookings(db)
b13 = next((b for b in bookings if getattr(b, 'id', '')==13), None)
print(f'num_rooms={getattr(b13, "num_rooms", None)}, room_type_name={getattr(b13, "room_type_name", None)}')
