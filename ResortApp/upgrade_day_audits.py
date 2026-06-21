import os
import sys
# Add ResortApp to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from app.database import engine
from sqlalchemy import text

def add_columns():
    cols = [
        ("opening_account_balance", "FLOAT DEFAULT 0.0"),
        ("closing_account_balance", "FLOAT DEFAULT 0.0"),
        ("system_expected_cash", "FLOAT DEFAULT 0.0"),
        ("system_expected_account", "FLOAT DEFAULT 0.0"),
        ("override_reason", "TEXT"),
        ("total_purchases", "FLOAT DEFAULT 0.0")
    ]
    
    print("Starting migration for day_audits table...")
    for col_name, col_type in cols:
        with engine.begin() as conn:
            try:
                conn.execute(text(f"ALTER TABLE day_audits ADD COLUMN {col_name} {col_type}"))
                print(f"SUCCESS: Added column {col_name}")
            except Exception as e:
                if "already exists" in str(e).lower():
                    print(f"INFO: Column {col_name} already exists")
                else:
                    print(f"ERROR: Failed to add {col_name}: {e}")

if __name__ == "__main__":
    add_columns()
