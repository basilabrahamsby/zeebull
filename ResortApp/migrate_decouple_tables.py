import os
import sys
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# Load environment variables
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("[ERROR] DATABASE_URL environment variable is not set in .env file.")
    sys.exit(1)

print(f"Connecting to database: {DATABASE_URL}...")
engine = create_engine(DATABASE_URL)

def run_migration():
    with engine.begin() as conn:
        print("\nStep 1: Creating 'restaurant_tables' table if not exists...")
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS restaurant_tables (
                id SERIAL PRIMARY KEY,
                table_number VARCHAR NOT NULL,
                seating_capacity INTEGER DEFAULT 4,
                status VARCHAR DEFAULT 'Available',
                branch_id INTEGER NOT NULL,
                CONSTRAINT uix_table_number_branch UNIQUE (table_number, branch_id)
            );
        """))
        print("[SUCCESS] 'restaurant_tables' table created or already exists.")

        print("\nStep 2: Adding 'table_id' to 'food_orders' table if not exists...")
        # Check if table_id already exists to prevent error in Postgres
        result = conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='food_orders' AND column_name='table_id';
        """)).fetchone()
        
        if not result:
            conn.execute(text("ALTER TABLE food_orders ADD COLUMN table_id INTEGER REFERENCES restaurant_tables(id) ON DELETE SET NULL;"))
            print("[SUCCESS] Column 'table_id' added to 'food_orders'.")
        else:
            print("[INFO] Column 'table_id' already exists in 'food_orders'.")

        print("\nStep 3: Modifying 'service_requests' table...")
        # Make room_id nullable
        conn.execute(text("ALTER TABLE service_requests ALTER COLUMN room_id DROP NOT NULL;"))
        print("[SUCCESS] Column 'room_id' in 'service_requests' made NULLABLE.")

        # Add table_id to service_requests
        result_sr = conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='service_requests' AND column_name='table_id';
        """)).fetchone()
        
        if not result_sr:
            conn.execute(text("ALTER TABLE service_requests ADD COLUMN table_id INTEGER REFERENCES restaurant_tables(id) ON DELETE SET NULL;"))
            print("[SUCCESS] Column 'table_id' added to 'service_requests'.")
        else:
            print("[INFO] Column 'table_id' already exists in 'service_requests'.")

        print("\nStep 4: Finding fake tables in 'rooms' table (names starting with 't' or 'T' followed by a digit)...")
        fake_rooms = conn.execute(text("SELECT id, number, branch_id FROM rooms WHERE number ~* '^t[0-9]';")).fetchall()
        
        if not fake_rooms:
            print("[INFO] No fake room tables found starting with 't'.")
            return

        print(f"[INFO] Found {len(fake_rooms)} fake rooms starting with 't'. Migrating to 'restaurant_tables'...")

        for room_id, number, branch_id in fake_rooms:
            # Map table number dynamically, e.g., 't02' -> 'Table t02' or keep as 't02' (wait, keep number exact so waiter screen matches!)
            table_name = number
            print(f"  -> Migrating fake room ID {room_id} ('{number}') to restaurant table...")
            
            # Check if table already exists in restaurant_tables
            existing_table = conn.execute(text("""
                SELECT id FROM restaurant_tables WHERE table_number = :number AND branch_id = :branch_id;
            """), {"number": table_name, "branch_id": branch_id}).fetchone()

            if not existing_table:
                insert_res = conn.execute(text("""
                    INSERT INTO restaurant_tables (table_number, seating_capacity, status, branch_id)
                    VALUES (:number, 4, 'Available', :branch_id)
                    RETURNING id;
                """), {"number": table_name, "branch_id": branch_id}).fetchone()
                table_db_id = insert_res[0]
                print(f"     Created new dining table record ID {table_db_id} for table '{table_name}'.")
            else:
                table_db_id = existing_table[0]
                print(f"     Dining table record already exists (ID {table_db_id}).")

            # Remap food orders
            orders_updated = conn.execute(text("""
                UPDATE food_orders 
                SET table_id = :table_id, room_id = NULL 
                WHERE room_id = :room_id
                RETURNING id;
            """), {"table_id": table_db_id, "room_id": room_id}).fetchall()
            
            if orders_updated:
                print(f"     Updated {len(orders_updated)} food orders from room_id={room_id} to table_id={table_db_id}.")

            # Remap service requests
            requests_updated = conn.execute(text("""
                UPDATE service_requests 
                SET table_id = :table_id, room_id = NULL 
                WHERE room_id = :room_id
                RETURNING id;
            """), {"table_id": table_db_id, "room_id": room_id}).fetchall()
            
            if requests_updated:
                print(f"     Updated {len(requests_updated)} service requests from room_id={room_id} to table_id={table_db_id}.")

            # Clean up dummy room
            conn.execute(text("DELETE FROM rooms WHERE id = :room_id;"), {"room_id": room_id})
            print(f"     [DELETED] Fake room record '{number}' (ID {room_id}) from 'rooms' table.")

        print("\n[MIGRATION COMPLETED SUCCESSFULLY]")

if __name__ == "__main__":
    try:
        run_migration()
    except Exception as e:
        print(f"\n[ERROR] Migration failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
