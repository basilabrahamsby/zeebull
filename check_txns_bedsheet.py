import psycopg2

def check_txns():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT t.id, i.name, t.transaction_type, t.quantity, t.reference_number, t.notes FROM inventory_transactions t JOIN inventory_items i ON t.item_id = i.id WHERE i.id = 30 ORDER BY t.created_at DESC")
        txns = cur.fetchall()
        print("Bed Sheet Transactions:")
        for t in txns:
            print(t)
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_txns()
