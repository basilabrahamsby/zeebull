import psycopg2

def check_config():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        
        # Check Item 30
        cur.execute("SELECT id, name, is_asset_fixed, track_laundry_cycle FROM inventory_items WHERE id = 30")
        item = cur.fetchone()
        print(f"Item 30: {item}")
        
        # Check Laundry Locations
        cur.execute("SELECT id, name, location_type FROM locations WHERE location_type = 'LAUNDRY'")
        laundries = cur.fetchall()
        print(f"Laundry Locations: {laundries}")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_config()
