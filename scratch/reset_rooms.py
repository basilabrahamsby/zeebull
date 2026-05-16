from sqlalchemy import create_engine, text

DATABASE_URL = "postgresql+psycopg2://postgres:qwerty123@localhost:5432/zeebull"
engine = create_engine(DATABASE_URL)

def reset_rooms():
    with engine.begin() as conn:
        res = conn.execute(text("UPDATE rooms SET status = 'Available'"))
        print(f"Updated {res.rowcount} rooms to Available")
        
        # Also sync inventory just in case
        res2 = conn.execute(text("UPDATE room_types rt SET total_inventory = (SELECT count(*) FROM rooms r WHERE r.room_type_id = rt.id)"))
        print(f"Synced inventory for {res2.rowcount} room types")

if __name__ == "__main__":
    reset_rooms()
