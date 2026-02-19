import psycopg2

def add_column():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
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
