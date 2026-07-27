import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load env
load_dotenv("c:\\releasing\\New Orchid\\ResortApp\\.env")
db_url = os.getenv("DATABASE_URL")

print(f"Connecting to database: {db_url}")
engine = create_engine(db_url)

with engine.connect() as conn:
    # Find bookings with duplicate external_id
    result = conn.execute(text("""
        SELECT external_id, COUNT(*), string_agg(display_id, ', ')
        FROM bookings
        WHERE external_id IS NOT NULL AND external_id != ''
        GROUP BY external_id
        HAVING COUNT(*) > 1;
    """))
    
    duplicates = result.fetchall()
    print(f"\nDuplicate external_ids found: {len(duplicates)}")
    for ext_id, count, displays in duplicates:
        print(f"External ID: {ext_id} | Count: {count} | Bookings: {displays}")

    # Print out some details of these duplicate bookings
    if duplicates:
        print("\nDetails of duplicate bookings:")
        for ext_id, _, _ in duplicates:
            result = conn.execute(text("""
                SELECT id, display_id, guest_name, check_in, check_out, total_amount, status, created_at
                FROM bookings
                WHERE external_id = :ext_id
                ORDER BY id ASC;
            """), {"ext_id": ext_id})
            rows = result.fetchall()
            print(f"--- External ID: {ext_id} ---")
            for row in rows:
                print(f"  ID: {row[0]} | Display ID: {row[1]} | Guest: {row[2]} | CheckIn: {row[3]} | CheckOut: {row[4]} | Amount: {row[5]} | Status: {row[6]} | CreatedAt: {row[7]}")
