import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.room import Room

db = SessionLocal()
statuses = [r[0] for r in db.query(Room.status).distinct().all()]
print("Room Statuses:", statuses)

# Also check Room 301 status
r301 = db.query(Room).filter(Room.number == '301').first()
if r301:
    print(f"Room 301 ID: {r301.id}, Number: {r301.number}, Status: {r301.status}")

db.close()
