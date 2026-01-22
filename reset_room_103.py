
import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Load .env from the correct location for the running service
load_dotenv("/var/www/inventory/ResortApp/.env")

# Get DB URL from env
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found in .env!")
    exit(1)

print(f"Connecting to DB...")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

def reset_room_103():
    print("--- Resetting Room 103 Inventory & Transactions ---")
    
    # 1. Find Room 103 Location
    # We look for the one with code LOC-RM-103 as established
    with engine.connect() as conn:
        result = conn.execute(text("SELECT id, name, location_code FROM locations WHERE location_code = 'LOC-RM-103'"))
        room_loc = result.fetchone()
        
        if not room_loc:
            # Fallback search by name
            result = conn.execute(text("SELECT id, name, location_code FROM locations WHERE name LIKE '%Room 103%' LIMIT 1"))
            room_loc = result.fetchone()
            
        if not room_loc:
            print("❌ Room 103 Location not found!")
            return

        print(f"✅ Found Room 103: ID={room_loc.id}, Name={room_loc.name}, Code={room_loc.location_code}")
        room_id = room_loc.id

        # 2. Find Central Warehouse (Destination for returns)
        result = conn.execute(text("SELECT id, name FROM locations WHERE location_type = 'CENTRAL_WAREHOUSE' LIMIT 1"))
        warehouse = result.fetchone()
        
        if not warehouse:
            # Fallback search
            result = conn.execute(text("SELECT id, name FROM locations WHERE name LIKE '%Main Store%' LIMIT 1"))
            warehouse = result.fetchone()
            
        if not warehouse:
            print("❌ Central Warehouse/Store not found! Cannot return items.")
            return
            
        print(f"✅ Found Warehouse: ID={warehouse.id}, Name={warehouse.name}")
        warehouse_id = warehouse.id

        # 3. Return Stock Items
        print("\n--- Returning Stock to Warehouse ---")
        stocks = conn.execute(text("SELECT id, item_id, quantity FROM location_stocks WHERE location_id = :room_id"), {"room_id": room_id}).fetchall()
        
        count_moved = 0
        for stock in stocks:
            qty = stock.quantity
            if qty > 0:
                # Add to Warehouse
                # Check if exists in warehouse
                wh_stock = conn.execute(text("SELECT id, quantity FROM location_stocks WHERE location_id = :wh_id AND item_id = :item_id"), 
                                      {"wh_id": warehouse_id, "item_id": stock.item_id}).fetchone()
                
                if wh_stock:
                    new_qty = wh_stock.quantity + qty
                    conn.execute(text("UPDATE location_stocks SET quantity = :qty WHERE id = :id"), {"qty": new_qty, "id": wh_stock.id})
                else:
                    conn.execute(text("INSERT INTO location_stocks (location_id, item_id, quantity) VALUES (:wh_id, :item_id, :qty)"),
                               {"wh_id": warehouse_id, "item_id": stock.item_id, "qty": qty})
                
                print(f"  Moved Item ID {stock.item_id}: {qty} units -> Warehouse")
                count_moved += 1
        
        # Delete stocks from Room
        conn.execute(text("DELETE FROM location_stocks WHERE location_id = :room_id"), {"room_id": room_id})
        print(f"  Deleted {len(stocks)} stock records from Room 103.")

        # 4. Return/Unassign Asset Mappings
        print("\n--- Moving Asset Mappings to Warehouse ---")
        mappings = conn.execute(text("SELECT id, item_id FROM asset_mappings WHERE location_id = :room_id"), {"room_id": room_id}).fetchall()
        
        for m in mappings:
            # Update location to warehouse
            conn.execute(text("UPDATE asset_mappings SET location_id = :wh_id WHERE id = :id"), {"wh_id": warehouse_id, "id": m.id})
            print(f"  Moved Asset Mapping ID {m.id} (Item {m.item_id}) -> Warehouse")
            
        print(f"  Moved {len(mappings)} asset mappings.")

        # 5. Clear Transaction History (Stock Issues)
        print("\n--- Clearing Transaction History ---")
        # Find issues where room was source OR destination
        issues = conn.execute(text("SELECT id FROM stock_issues WHERE source_location_id = :room_id OR destination_location_id = :room_id"), {"room_id": room_id}).fetchall()
        issue_ids = [row.id for row in issues]
        
        if issue_ids:
            # Delete details first (FK)
            # Need to format list for SQL IN clause safe? 
            # Using tuple(issue_ids) with psycopg2 usually works with IN default params, 
            # but safer to loop or use text binding dynamically if list is small. 
            # Or assume cascade delete? Let's try explicit delete.
            
            # Using simple loop for safety
            for iid in issue_ids:
                conn.execute(text("DELETE FROM stock_issue_details WHERE issue_id = :iid"), {"iid": iid})
            
            # Now delete issues
            for iid in issue_ids:
                conn.execute(text("DELETE FROM stock_issues WHERE id = :iid"), {"iid": iid})
                
            print(f"  Deleted {len(issue_ids)} stock issue transactions involving Room 103.")
        else:
            print("  No transaction history found.")

        conn.commit()
        print("\n✅ SUCCESS: Room 103 has been reset. All items returned to Warehouse.")

if __name__ == "__main__":
    reset_room_103()
