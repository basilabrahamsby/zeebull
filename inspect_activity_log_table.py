
import sys
import os
sys.path.append('/var/www/inventory/ResortApp')
from app.database import SessionLocal, engine
from sqlalchemy import inspect

def check_table():
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    if 'activity_logs' in tables:
        print("Table 'activity_logs' EXISTS.")
        columns = [c['name'] for c in inspector.get_columns('activity_logs')]
        print(f"Columns: {columns}")
    else:
        print("Table 'activity_logs' does NOT exist.")
        # Print similar names?
        print(f"All tables: {tables}")

if __name__ == "__main__":
    check_table()
