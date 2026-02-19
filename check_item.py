import psycopg2

def check_item():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT id, name, is_asset_fixed, track_laundry_cycle FROM inventory_items WHERE name ILIKE '%bed sheet%'")
        items = cur.fetchall()
        print("Bedsheet Item Info:")
        for item in items:
            print(item)
            
        cur.execute("SELECT id, name, location_type FROM locations")
        locs = cur.fetchall()
        print("\nLocations:")
        for loc in locs:
            print(loc)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_item()
