
import psycopg2
import os

# Connect to database using env vars or default
db_name = os.getenv("POSTGRES_DB", "orchid_resort")
db_user = os.getenv("POSTGRES_USER", "orchid_user")
db_password = os.getenv("POSTGRES_PASSWORD", "admin123")
db_host = os.getenv("POSTGRES_SERVER", "localhost")

print(f"Connecting to DB: {db_name} as {db_user} on {db_host}")

def add_column():
    try:
        conn = psycopg2.connect(dbname=db_name, user=db_user, password=db_password, host=db_host)
        conn.autocommit = True
        cur = conn.cursor()
        
        # Check if column exists
        cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name='service_requests' AND column_name='pickup_location_id'")
        if not cur.fetchone():
            print("Adding pickup_location_id to service_requests...")
            cur.execute("ALTER TABLE service_requests ADD COLUMN pickup_location_id INTEGER REFERENCES locations(id)")
            print("Column added.")
        else:
            print("Column already exists.")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    add_column()
