from sqlalchemy import create_engine, inspect
import os

# Try local DB URL from .env
SQLALCHEMY_DATABASE_URL = "postgresql://postgres:qwerty123@localhost/orchiddb"

try:
    engine = create_engine(SQLALCHEMY_DATABASE_URL)
    inspector = inspect(engine)
    columns = [col['name'] for col in inspector.get_columns('bookings')]
    print(f"Columns in 'bookings' table: {columns}")
    
    missing = []
    for col in ['source', 'package_name', 'special_requests', 'preferences']:
        if col not in columns:
            missing.append(col)
    
    if missing:
        print(f"MISSING COLUMNS: {missing}")
    else:
        print("No missing columns in 'bookings' table.")
except Exception as e:
    print(f"Error checking local DB: {e}")
