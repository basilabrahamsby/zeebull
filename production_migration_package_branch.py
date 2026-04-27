import psycopg2
import sys
import os

# Client DB details
DB_NAME = "zeebuldb"
DB_USER = "postgres"
DB_PASS = "qwerty123"

def migrate_database():
    print("Connecting to local database...")
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASS,
            host="localhost"
        )
        conn.autocommit = True
        cur = conn.cursor()
        print("Successfully connected!")
        
        # Step 1: Assign any unassigned packages to branch 1 (ZeeBull Wild Villa)
        print("Checking for packages without a branch_id...")
        cur.execute("SELECT id, title FROM packages WHERE branch_id IS NULL;")
        null_packages = cur.fetchall()
        
        if null_packages:
            print(f"Found {len(null_packages)} packages without a branch. Assigning to branch_id = 1...")
            cur.execute("UPDATE packages SET branch_id = 1 WHERE branch_id IS NULL;")
            print("Packages updated.")
        else:
            print("No unassigned packages found.")
            
        # Step 2: Alter the column to enforce NOT NULL
        print("Enforcing NOT NULL constraint on packages.branch_id...")
        try:
            cur.execute("ALTER TABLE packages ALTER COLUMN branch_id SET NOT NULL;")
            print("Successfully altered packages table.")
        except psycopg2.Error as e:
            print(f"Notice: Constraint might already be set or another error occurred: {e}")
            
        cur.close()
        conn.close()
        print("Migration complete!")
        
    except psycopg2.OperationalError as e:
        print(f"Error connecting to the database: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    migrate_database()
