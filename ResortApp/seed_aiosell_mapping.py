import sys
import os

# Add current directory to sys.path
_BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(_BASE_DIR)

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.room import RoomType, RatePlan
from app.database import Base

# Use credentials from environment or defaults
DATABASE_URL = "postgresql+psycopg2://postgres:qwerty123@localhost:5432/zeebuldb"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

# Mappings provided by the user
ROOM_MAPPINGS = {
    "zeebull heritage room": "zeebull-heritage-room",
    "zeebull heritage cottage": "zeebull-heritage-cottage",
    "zeebull club room": "zeebull-club-room",
    "zeebull family cottage": "zeebull-family-cottage",
    "zeebull honeymoon cottage": "zeebull-honeymoon-cottage"
}

RATE_PLANS = [
    {"room": "zeebull-heritage-room", "name": "Single CP", "occ": 1, "meal": "CP", "id": "zeebull-heritage-room-s-cp"},
    {"room": "zeebull-heritage-room", "name": "Double CP", "occ": 2, "meal": "CP", "id": "zeebull-heritage-room-d-cp"},
    {"room": "zeebull-heritage-room", "name": "Triple CP", "occ": 3, "meal": "CP", "id": "zeebull-heritage-room-t-cp"},
    {"room": "zeebull-heritage-room", "name": "Quad CP", "occ": 4, "meal": "CP", "id": "zeebull-heritage-room-q-cp"},
    
    {"room": "zeebull-heritage-cottage", "name": "Single EP", "occ": 1, "meal": "EP", "id": "zeebull-heritage-cottage-s-ep"},
    {"room": "zeebull-heritage-cottage", "name": "Double EP", "occ": 2, "meal": "EP", "id": "zeebull-heritage-cottage-d-ep"},
    {"room": "zeebull-heritage-cottage", "name": "Triple EP", "occ": 3, "meal": "EP", "id": "zeebull-heritage-cottage-t-ep"},
    
    {"room": "zeebull-club-room", "name": "Single CP", "occ": 1, "meal": "CP", "id": "zeebull-club-room-s-cp"},
    {"room": "zeebull-club-room", "name": "Double CP", "occ": 2, "meal": "CP", "id": "zeebull-club-room-d-cp"},
    {"room": "zeebull-club-room", "name": "Triple CP", "occ": 3, "meal": "CP", "id": "zeebull-club-room-t-cp"},
    
    {"room": "zeebull-family-cottage", "name": "Single CP", "occ": 1, "meal": "CP", "id": "zeebull-family-cottage-s-cp"},
    {"room": "zeebull-family-cottage", "name": "Double CP", "occ": 2, "meal": "CP", "id": "zeebull-family-cottage-d-cp"},
    {"room": "zeebull-family-cottage", "name": "Triple CP", "occ": 3, "meal": "CP", "id": "zeebull-family-cottage-t-cp"},
    {"room": "zeebull-family-cottage", "name": "Quad CP", "occ": 4, "meal": "CP", "id": "zeebull-family-cottage-q-cp"},
    
    {"room": "zeebull-honeymoon-cottage", "name": "Single CP", "occ": 1, "meal": "CP", "id": "zeebull-honeymoon-cottage-s-cp"},
    {"room": "zeebull-honeymoon-cottage", "name": "Double CP", "occ": 2, "meal": "CP", "id": "zeebull-honeymoon-cottage-d-cp"},
    {"room": "zeebull-honeymoon-cottage", "name": "Triple CP", "occ": 3, "meal": "CP", "id": "zeebull-honeymoon-cottage-t-cp"},
    {"room": "zeebull-honeymoon-cottage", "name": "Quad CP", "occ": 4, "meal": "CP", "id": "zeebull-honeymoon-cottage-q-c"},
]

print("--- Starting Seeding ---")

# 1. Update Room Types
for internal_name, cm_id in ROOM_MAPPINGS.items():
    rt = db.query(RoomType).filter(RoomType.name.ilike(internal_name)).first()
    if rt:
        print(f"Updating RoomType '{rt.name}' with CM ID: {cm_id}")
        rt.channel_manager_id = cm_id
        db.commit()
    else:
        print(f"Warning: RoomType '{internal_name}' not found in database.")

# 2. Add Rate Plans
for plan in RATE_PLANS:
    # Find the room type by CM ID
    rt = db.query(RoomType).filter(RoomType.channel_manager_id == plan["room"]).first()
    if rt:
        # Check if plan already exists
        existing = db.query(RatePlan).filter(RatePlan.channel_manager_id == plan["id"]).first()
        if not existing:
            print(f"Adding Rate Plan '{plan['name']}' for '{rt.name}'")
            db_plan = RatePlan(
                name=plan["name"],
                room_type_id=rt.id,
                occupancy=plan["occ"],
                meal_plan=plan["meal"],
                channel_manager_id=plan["id"],
                branch_id=rt.branch_id
            )
            db.add(db_plan)
            db.commit()
        else:
            print(f"Rate Plan '{plan['id']}' already exists.")
    else:
        print(f"Skipping rate plan '{plan['id']}' because room type '{plan['room']}' is not mapped.")

print("--- Seeding Complete ---")
db.close()
