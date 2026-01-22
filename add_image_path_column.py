#!/usr/bin/env python3
"""Add image_path column to service_requests table"""

import sys
import os

# Add the ResortApp directory to the path
sys.path.insert(0, '/var/www/inventory/ResortApp')

from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv('/var/www/inventory/ResortApp/.env')

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    print("ERROR: DATABASE_URL not found in .env file")
    sys.exit(1)

print(f"Connecting to database...")
engine = create_engine(DATABASE_URL)

try:
    with engine.connect() as conn:
        # Check if column exists
        result = conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='service_requests' AND column_name='image_path'
        """))
        
        if result.fetchone():
            print("Column 'image_path' already exists in service_requests table")
        else:
            print("Adding 'image_path' column to service_requests table...")
            conn.execute(text("""
                ALTER TABLE service_requests 
                ADD COLUMN image_path VARCHAR
            """))
            conn.commit()
            print("✓ Column added successfully")
            
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)

print("Done!")
