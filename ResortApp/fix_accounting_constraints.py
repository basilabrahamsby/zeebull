from app.database import engine
from sqlalchemy import text
import sys

def fix_constraints():
    print("Fixing database constraints for accounting tables...")
    try:
        with engine.connect() as conn:
            # Drop old constraints
            conn.execute(text('ALTER TABLE account_groups DROP CONSTRAINT IF EXISTS account_groups_name_key'))
            conn.execute(text('ALTER TABLE account_ledgers DROP CONSTRAINT IF EXISTS account_ledgers_code_key'))
            
            # Add new composite constraints if they don't exist
            # Note: We use try/except because Postgres doesn't have ADD CONSTRAINT IF NOT EXISTS
            try:
                conn.execute(text('ALTER TABLE account_groups ADD CONSTRAINT _name_branch_uc UNIQUE (name, branch_id)'))
                print("  + Added unique constraint to account_groups")
            except Exception as e:
                print(f"  - Note: account_groups constraint might already exist or could not be added: {e}")
                conn.rollback()
            
            try:
                conn.execute(text('ALTER TABLE account_ledgers ADD CONSTRAINT _ledger_name_branch_uc UNIQUE (name, branch_id)'))
                print("  + Added unique constraint to account_ledgers")
            except Exception as e:
                print(f"  - Note: account_ledgers constraint might already exist or could not be added: {e}")
                conn.rollback()
                
            conn.commit()
            print("Database constraints updated successfully.")
    except Exception as e:
        print(f"ERROR: {e}")

if __name__ == "__main__":
    fix_constraints()
