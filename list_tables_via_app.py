
import sys
import os

# Add the app directory to sys.path
sys.path.append('/var/www/inventory/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

def list_all_tables():
    db = SessionLocal()
    try:
        result = db.execute(text("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """))
        tables = [row[0] for row in result.fetchall()]
        return sorted(tables)
    finally:
        db.close()

if __name__ == "__main__":
    tables = list_all_tables()
    print("TABLES_START")
    for t in tables:
        print(t)
    print("TABLES_END")
