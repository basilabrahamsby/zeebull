from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.room import Room
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

rs = session.query(Room).filter(Room.number.in_(["101", "103"])).all()
for r in rs:
    print(f"Room {r.number}: {r.status}")
