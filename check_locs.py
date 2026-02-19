import psycopg2

def check_locs():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT id, name, location_type FROM locations")
        locs = cur.fetchall()
        print("Locations:")
        for l in locs:
            print(f"{l[0]}: {l[1]} ({l[2]})")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_locs()
