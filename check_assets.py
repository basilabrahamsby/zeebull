import psycopg2

def check_assets():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT id, item_id, current_location_id, status FROM asset_registry WHERE item_id = 30")
        assets = cur.fetchall()
        print("Asset Registry (bed sheet):")
        for a in assets:
            print(f"  ID {a[0]}: Item {a[1]}, Location {a[2]}, Status {a[3]}")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_assets()
