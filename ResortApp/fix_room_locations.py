from app.database import SessionLocal
from app.models.room import Room
from app.models.inventory import Location

db = SessionLocal()
rooms = db.query(Room).all()
fixed = 0

for room in rooms:
    # Find the correct location for this room in the SAME branch
    correct_location = db.query(Location).filter(
        Location.name == 'Room ' + str(room.number),
        Location.branch_id == room.branch_id,
        Location.location_type == 'GUEST_ROOM'
    ).first()
    
    if correct_location and room.inventory_location_id != correct_location.id:
        print(f'Fixing Room {room.number} (Branch {room.branch_id}): loc {room.inventory_location_id} -> {correct_location.id}')
        room.inventory_location_id = correct_location.id
        fixed += 1

db.commit()
print(f'Fixed {fixed} rooms.')
