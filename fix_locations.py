
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
# Import Base to ensure models are compatible, but we bind engine separately
from app.database import Base 

# Load .env from the correct location for the running service
load_dotenv("/var/www/inventory/ResortApp/.env")

# Get DB URL from env
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found in .env!")
    exit(1)

print(f"Connecting to: {DATABASE_URL}")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

from app.models.inventory import Location, LocationStock, StockIssue, AssetMapping, StockIssueDetail
from app.models.room import Room
from sqlalchemy import func, text

def inspect_tables():
    print("--- Inspecting Tables ---")
    with engine.connect() as conn:
        result = conn.execute(text("SELECT table_name FROM information_schema.tables WHERE table_schema='public'"))
        tables = [row[0] for row in result]
        print(f"Tables found: {tables}")
inspect_tables()

db = SessionLocal()

db = SessionLocal()

def fix_room_103():
    print("--- Fixing Room 103 Duplicates ---")
    # Finding Location entries for Room 103
    locs = db.query(Location).filter(Location.name.like("%Room 103%")).all()
    
    if len(locs) < 2:
        print("Less than 2 locations found for Room 103. Nothing to merge.")
        for l in locs:
            print(f"Prop: ID={l.id}, Code={l.location_code}, Name={l.name}, Type={l.location_type}")
        return

    # Identify source and target by LOCATION CODE
    # Screenshot showed LOC-RM-103 and LOC-RM-12.
    # LOC-RM-103 is the desired code.
    
    target = next((l for l in locs if l.location_code == 'LOC-RM-103'), None)
    
    # If explicit target not found, pick the one that looks like 'LOC-RM-103'
    if not target:
        target = next((l for l in locs if l.location_code and 'LOC-RM-103' in l.location_code), None)
        
    if not target:
         print("Could not find target 'LOC-RM-103'. Listing all options:")
         for l in locs:
             print(f"ID={l.id}, Code={l.location_code}, Name={l.name}")
         # Fallback manual selection or abort
         return

    # Source is any other Room 103 location
    sources = [l for l in locs if l.id != target.id]
    
    if not sources:
        print("No sources to merge from.")
        return

    for source in sources:
        print(f"Merging FROM source ID {source.id} ({source.location_code}) TO target ID {target.id} ({target.location_code})")

        # 1. Move LocationStock
        source_stocks = db.query(LocationStock).filter(LocationStock.location_id == source.id).all()
        for stock in source_stocks:
            print(f"  Moving stock item {stock.item_id} qty {stock.quantity}")
            # Check if target has this item
            target_stock = db.query(LocationStock).filter(
                LocationStock.location_id == target.id, 
                LocationStock.item_id == stock.item_id
            ).first()
            
            if target_stock:
                target_stock.quantity += stock.quantity
                print(f"    Merged. New qty: {target_stock.quantity}")
                db.delete(stock)
            else:
                stock.location_id = target.id
                print(f"    Moved.")
        
        # 2. Move AssetMappings
        mappings = db.query(AssetMapping).filter(AssetMapping.location_id == source.id).all()
        for m in mappings:
            print(f"  Moving mapping item {m.item_id}")
            m.location_id = target.id
            
        # 3. Move StockIssues (Destination)
        issues_in = db.query(StockIssue).filter(StockIssue.destination_location_id == source.id).all()
        for i in issues_in:
            i.destination_location_id = target.id
            
        # 4. Move StockIssues (Source)
        issues_out = db.query(StockIssue).filter(StockIssue.source_location_id == source.id).all()
        for i in issues_out:
            i.source_location_id = target.id
        
        # 5. Move Room association (if any)
        try:
             db.execute(text("UPDATE rooms SET inventory_location_id = :target_id WHERE inventory_location_id = :source_id"), {"target_id": target.id, "source_id": source.id})
             print(f"  Updated Room association from {source.id} to {target.id}")
        except Exception as e:
             print(f"  Generic error updating rooms (maybe table name differs?): {e}")

        db.commit()
        print("  Merge steps committed.")
        
        # Check if safe to delete source
        # Force refresh checks
        remaining_stock = db.query(LocationStock).filter(LocationStock.location_id == source.id).count()
        remaining_mappings = db.query(AssetMapping).filter(AssetMapping.location_id == source.id).count()
        
        if remaining_stock == 0 and remaining_mappings == 0:
            print(f"  Deleting source location {source.id}")
            db.delete(source)
            db.commit()
        else:
            print(f"  WARNING: Source location {source.id} still has dependencies. Stock: {remaining_stock}, Mappings: {remaining_mappings}")

def cleanup_orphaned_locations():
    print("\n--- Cleaning Orphaned Locations ---")
    guest_locs = db.query(Location).filter(Location.location_type == 'GUEST_ROOM').all()
    rooms = db.query(Room).all()
    
    # Build list of valid room identifiers
    room_numbers = set()
    for r in rooms:
        room_numbers.add(str(r.number))
    
    print(f"Active Room Numbers: {room_numbers}")
    
    for loc in guest_locs:
        # Check if this location matches a room
        # Match strategy: 
        # 1. location_code ends with room number (e.g., LOC-RM-101)
        # 2. exact name match
        
        matches = False
        loc_room_num = str(loc.room_area) if loc.room_area else ""
        
        # Extract number from code if possible
        code_num = ""
        if loc.location_code and "RM-" in loc.location_code:
            code_num = loc.location_code.split("RM-")[-1]
            
        if loc_room_num in room_numbers:
            matches = True
        elif code_num in room_numbers:
            matches = True
        elif loc.name.replace("Room ", "") in room_numbers:
            matches = True
            
        if not matches:
            print(f"Found orphaned location: ID={loc.id} Code={loc.location_code} Name='{loc.name}' Area='{loc.room_area}'")
            
            # Additional safety: Don't delete if it has stock, unless forced?
            # User said "deleted rooms are not removed". So we should remove them even if they have stock?
            # No, if they have stock, we shouldn't lose the stock record ideally. We should move it to Lost & Found or Warehouse?
            # For now, I'll delete ONLY if empty, to be safe. If stock exists, I'll print warning.
            
            stock_count = db.query(LocationStock).filter(LocationStock.location_id == loc.id).filter(LocationStock.quantity > 0).count()
            
            if stock_count == 0:
                print(f"  -> No stock. Deleting.")
                db.delete(loc)
            else:
                print(f"  -> Has {stock_count} stock items. SKIPPING DELETE to prevent data loss. Please manually verify.")

    db.commit()
    print("Cleanup complete.")

if __name__ == "__main__":
    fix_room_103()
    cleanup_orphaned_locations()
