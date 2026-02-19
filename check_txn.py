import psycopg2

def check_txn():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        cur.execute("SELECT id, transaction_type, reference_number, notes FROM inventory_transactions WHERE reference_number = 'WASTE-20260219-001'")
        txn = cur.fetchone()
        print(f"Transaction: {txn}")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_txn()
