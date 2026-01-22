
import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

# Load .env
load_dotenv("/var/www/inventory/ResortApp/.env")
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found!")
    sys.exit(1)

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
db = SessionLocal()

def clean_room_dependencies(room_number="103"):
    print(f"--- Cleaning Dependencies for Room {room_number} ---")
    
    with engine.connect() as conn:
        # 1. Find the Room ID
        result = conn.execute(text("SELECT id FROM rooms WHERE number = :num"), {"num": room_number})
        room = result.fetchone()
        
        if not room:
            print(f"Room {room_number} not found in DB. Searching for similar...")
            rooms = conn.execute(text("SELECT id, number FROM rooms WHERE number LIKE :num"), {"num": f"%{room_number}%"}).fetchall()
            if not rooms:
                print("No active rooms found matching 103.")
                # Maybe query all?
                all_rooms = conn.execute(text("SELECT id, number FROM rooms LIMIT 5")).fetchall()
                print(f"Sample rooms: {all_rooms}")
                return
            
            print(f"Found matches: {rooms}")
            # Use the first one
            room_id = rooms[0].id
            print(f"Using Room ID: {room_id} (Number: {rooms[0].number})")
        else:
            room_id = room.id
            print(f"Found Room ID: {room_id}")

        # 2. Check & Clear Food Orders
        orders = conn.execute(text("SELECT count(*) FROM food_orders WHERE room_id = :rid"), {"rid": room_id}).scalar()
        print(f"Found {orders} Food Orders.")
        if orders > 0:
            conn.execute(text("DELETE FROM food_order_items WHERE order_id IN (SELECT id FROM food_orders WHERE room_id = :rid)"), {"rid": room_id})
            conn.execute(text("DELETE FROM food_orders WHERE room_id = :rid"), {"rid": room_id})
            print("  Deleted Food Orders.")

        # 3. Check & Clear Service Requests (Assigned Services, etc.)
        # Need to check table names. Likely 'assigned_services' or 'service_requests'
        # Inspect tables first to be sure
        tables = conn.execute(text("SELECT table_name FROM information_schema.tables WHERE table_schema='public'")).fetchall()
        table_names = [t[0] for t in tables]
        
        if 'assigned_services' in table_names:
            cnt = conn.execute(text("SELECT count(*) FROM assigned_services WHERE room_id = :rid"), {"rid": room_id}).scalar()
            print(f"Found {cnt} Assigned Services.")
            if cnt > 0:
                # Find Service IDs first
                svc_ids = conn.execute(text("SELECT id FROM assigned_services WHERE room_id = :rid"), {"rid": room_id}).fetchall()
                if svc_ids:
                    svc_id_list = [s[0] for s in svc_ids]
                    # Check if employee_inventory_assignments table exists
                    if 'employee_inventory_assignments' in table_names:
                        # Construct IN clause manually or loop
                        # Using loop for simplicity and safety
                        for sid in svc_id_list:
                            conn.execute(text("DELETE FROM employee_inventory_assignments WHERE assigned_service_id = :sid"), {"sid": sid})
                        print("  Deleted related Employee Inventory Assignments.")
                
                conn.execute(text("DELETE FROM assigned_services WHERE room_id = :rid"), {"rid": room_id})
                print("  Deleted Assigned Services.")
                
        # 4. Check Booking Rooms (If cascade fails)
        # We won't delete bookings, but we might need to remove the link if booking is cancelled?
        # Actually, user wants to DELETE the room.
        # If we remove BookingRoom rows, the booking loses the room info but exists.
        # This is better than deleting the booking entirely if we want to keep financial record?
        # But if the user wants to delete the room, they probably don't care about the link.
        
        # However, active bookings prevent deletion logically.
        # Let's CANCEL any active bookings for this room.
        
        # Find bookings with this room
        active_bookings = conn.execute(text("""
            SELECT b.id, b.status 
            FROM bookings b
            JOIN booking_rooms br ON b.id = br.booking_id
            WHERE br.room_id = :rid AND b.status NOT IN ('CANCELLED', 'CHECKED_OUT')
        """), {"rid": room_id}).fetchall()
        
        for b in active_bookings:
            print(f"Found Active Booking ID {b.id} Status {b.status}. Cancelling...")
            conn.execute(text("UPDATE bookings SET status = 'CANCELLED' WHERE id = :bid"), {"bid": b.id})
            
        # 5. Clear Expenses (if any linked to room)
        if 'expenses' in table_names:
             # Check if expenses have room_id column
             cols = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name='expenses'")).fetchall()
             col_names = [c[0] for c in cols]
             if 'room_id' in col_names:
                 conn.execute(text("DELETE FROM expenses WHERE room_id = :rid"), {"rid": room_id})
                 print("  Deleted Expenses linked to room.")

        conn.commit()
        print("Dependencies cleaned. You should be able to delete the room now.")

if __name__ == "__main__":
    clean_room_dependencies("103")
