import sys
import os
from sqlalchemy import text, create_engine

# Add ResortApp to path
sys.path.append(os.path.abspath("ResortApp"))

DATABASE_URL = "postgresql+psycopg2://postgres:qwerty123@localhost:5432/zeebull"
engine = create_engine(DATABASE_URL)

def check_availability():
    with engine.connect() as conn:
        print("--- Room Types ---")
        rt_result = conn.execute(text("SELECT id, name, total_inventory FROM room_types"))
        for rt in rt_result:
            print(f"ID: {rt.id}, Name: {rt.name}, Total Inventory: {rt.total_inventory}")
            
        print("\n--- Rooms ---")
        r_result = conn.execute(text("SELECT id, number, room_type_id, status FROM rooms"))
        for r in r_result:
            print(f"ID: {r.id}, No: {r.number}, TypeID: {r.room_type_id}, Status: {r.status}")

if __name__ == "__main__":
    check_availability()
