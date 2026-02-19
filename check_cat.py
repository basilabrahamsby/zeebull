import psycopg2

def check_cat():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT i.id, i.name, c.name, c.classification FROM inventory_items i JOIN inventory_categories c ON i.category_id = c.id WHERE i.name ILIKE '%bed sheet%'")
        items = cur.fetchall()
        print("Bedsheet Category Info:")
        for item in items:
            print(item)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_cat()
