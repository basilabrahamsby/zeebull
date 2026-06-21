from app.database import SessionLocal
from app.models.room import Room
from app.models.inventory import Location

def run():
    db = SessionLocal()
    rooms = db.query(Room).all()
    added = 0
    
    for r in rooms:
        existing = db.query(Location).filter(Location.name == 'Room ' + str(r.number), Location.branch_id == r.branch_id).first()
        if not existing:
            loc = Location(
                name='Room ' + str(r.number), 
                building='Main', 
                room_area='Room', 
                branch_id=r.branch_id, 
                location_type='GUEST_ROOM', 
                is_inventory_point=False, 
                is_active=True
            )
            db.add(loc)
            added += 1
            print(f"Created Location for Room {r.number}")
            
    db.commit()
    print(f"Successfully added {added} missing locations!")

if __name__ == "__main__":
    run()
