import psycopg2

def check_mappings():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT id, item_id, location_id, is_active FROM asset_mappings WHERE item_id = 30")
        mappings = cur.fetchall()
        print("Asset Mappings (bed sheet):")
        for m in mappings:
            print(f"  ID {m[0]}: Item {m[1]}, Location {m[2]}, Active {m[3]}")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_mappings()
