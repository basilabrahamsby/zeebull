import psycopg2

def check_stocks():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT ls.location_id, l.name, ls.quantity FROM location_stocks ls JOIN locations l ON ls.location_id = l.id WHERE ls.item_id = 30")
        stocks = cur.fetchall()
        print("Bed Sheet Stocks Across Locations:")
        for s in stocks:
            print(s)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_stocks()
