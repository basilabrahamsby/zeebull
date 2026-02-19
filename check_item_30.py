import psycopg2

def check_item_30():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT id, name, track_laundry_cycle, is_asset_fixed, current_stock FROM inventory_items WHERE id = 30")
        item = cur.fetchone()
        print(f"Item 30: {item}")
        
        cur.execute("SELECT location_id, quantity FROM location_stocks WHERE item_id = 30")
        stocks = cur.fetchall()
        print("Location Stocks:")
        for s in stocks:
            print(f"  Location {s[0]}: {s[1]}")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_item_30()
