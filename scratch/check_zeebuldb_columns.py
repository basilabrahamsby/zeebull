import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
from pathlib import Path

# Load env from ResortApp/.env
env_path = Path(__file__).parent.parent / "ResortApp" / ".env"
load_dotenv(dotenv_path=env_path)

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("Error: DATABASE_URL not found in .env")
    sys.exit(1)

print(f"Connecting to: {DATABASE_URL}")
engine = create_engine(DATABASE_URL)

def check_and_add(conn, table, column, col_type):
    # Check if column exists
    result = conn.execute(text(f"""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name='{table}' AND column_name='{column}'
    """)).fetchone()
    
    if result:
        print(f"Column '{column}' ALREADY EXISTS in table '{table}'.")
    else:
        print(f"Column '{column}' is MISSING in table '{table}'. Adding it...")
        try:
            conn.execute(text(f"ALTER TABLE {table} ADD COLUMN {column} {col_type}"))
            print(f"SUCCESS: Added column '{column}' to table '{table}'.")
        except Exception as e:
            print(f"ERROR adding column '{column}' to table '{table}': {e}")

with engine.connect() as conn:
    # 1. Check branches location
    check_and_add(conn, "branches", "location", "VARCHAR")
    
    # 2. Check notifications recipient_id
    check_and_add(conn, "notifications", "recipient_id", "INTEGER")
    
    # 3. Check stock_issues booking_id and guest_id
    check_and_add(conn, "stock_issues", "booking_id", "INTEGER")
    check_and_add(conn, "stock_issues", "guest_id", "INTEGER")
    
    # 4. Check inventory_transactions source_location_id and destination_location_id
    check_and_add(conn, "inventory_transactions", "source_location_id", "INTEGER")
    check_and_add(conn, "inventory_transactions", "destination_location_id", "INTEGER")
    
    # 5. Check package_bookings display_id
    check_and_add(conn, "package_bookings", "display_id", "VARCHAR")
    
    # 6. Check checkout columns
    checkout_cols = [
        ("late_checkout_fee", "FLOAT DEFAULT 0.0"),
        ("consumables_charges", "FLOAT DEFAULT 0.0"),
        ("inventory_charges", "FLOAT DEFAULT 0.0"),
        ("asset_damage_charges", "FLOAT DEFAULT 0.0"),
        ("key_card_fee", "FLOAT DEFAULT 0.0"),
        ("advance_deposit", "FLOAT DEFAULT 0.0"),
        ("tips_gratuity", "FLOAT DEFAULT 0.0"),
        ("bill_details", "JSON"),
        ("guest_gstin", "VARCHAR"),
        ("is_b2b", "BOOLEAN DEFAULT FALSE"),
        ("invoice_number", "VARCHAR"),
        ("invoice_pdf_path", "VARCHAR"),
        ("gate_pass_path", "VARCHAR"),
        ("feedback_sent", "BOOLEAN DEFAULT FALSE")
    ]
    for col, c_type in checkout_cols:
        check_and_add(conn, "checkouts", col, c_type)
        
    conn.commit()

print("Inspection and manual migrations completed.")
