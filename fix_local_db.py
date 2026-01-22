import psycopg2
from psycopg2 import sql

# Local DB connection
conn = psycopg2.connect("dbname=orchiddb user=postgres password=qwerty123 host=localhost")
cur = conn.cursor()

try:
    # Add columns to bookings table
    commands = [
        "ALTER TABLE bookings ADD COLUMN IF NOT EXISTS source VARCHAR(255) DEFAULT 'Direct';",
        "ALTER TABLE bookings ADD COLUMN IF NOT EXISTS package_name VARCHAR(255);",
        "ALTER TABLE bookings ADD COLUMN IF NOT EXISTS special_requests TEXT;",
        "ALTER TABLE bookings ADD COLUMN IF NOT EXISTS preferences TEXT;"
    ]
    
    for cmd in commands:
        print(f"Executing: {cmd}")
        cur.execute(cmd)
    
    conn.commit()
    print("Database columns added successfully.")
except Exception as e:
    print(f"Error: {e}")
    conn.rollback()
finally:
    cur.close()
    conn.close()
