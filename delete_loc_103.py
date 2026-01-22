
import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

load_dotenv("/var/www/inventory/ResortApp/.env")
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found!")
    sys.exit(1)

engine = create_engine(DATABASE_URL)
with engine.connect() as conn:
    print("--- Deleting Location for Room 103 ---")
    
    # query location
    loc = conn.execute(text("SELECT id, name FROM locations WHERE location_code = 'LOC-RM-103'")).fetchone()
    if not loc:
        loc = conn.execute(text("SELECT id, name FROM locations WHERE name LIKE '%Room 103%' AND location_type='GUEST_ROOM'")).fetchone()
        
    if not loc:
        print("Location Room 103 not found or already deleted.")
    else:
        print(f"Found Location: ID {loc.id} Name {loc.name}")
        # Check stock just in case (should be 0)
        stock = conn.execute(text("SELECT count(*) FROM location_stocks WHERE location_id = :lid AND quantity > 0"), {"lid": loc.id}).scalar()
        if stock > 0:
            print(f"WARNING: Location has {stock} stock items! Cannot delete safely. Please transfer stock first.")
        else:
            conn.execute(text("DELETE FROM locations WHERE id = :lid"), {"lid": loc.id})
            conn.commit()
            print("✅ Location Room 103 deleted.")
