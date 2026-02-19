import psycopg2
from datetime import datetime

def check_laundry():
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        
        # Check Laundry Logs
        cur.execute("""
            SELECT l.id, i.name, l.quantity, l.status, l.sent_at 
            FROM laundry_logs l 
            JOIN inventory_items i ON l.item_id = i.id 
            ORDER BY l.sent_at DESC LIMIT 5
        """)
        logs = cur.fetchall()
        print("Recent Laundry Logs:")
        for log in logs:
            print(log)
            
        # Check Transactions for Bed Sheet
        cur.execute("""
            SELECT t.id, i.name, t.transaction_type, t.quantity, t.reference_number, t.created_at
            FROM inventory_transactions t
            JOIN inventory_items i ON t.item_id = i.id
            WHERE i.name ILIKE '%bed sheet%'
            ORDER BY t.created_at DESC LIMIT 5
        """)
        txns = cur.fetchall()
        print("\nRecent Bed Sheet Transactions:")
        for txn in txns:
            print(txn)
            
        # Check Asset Registry status
        cur.execute("""
            SELECT a.id, i.name, a.status, a.current_location_id
            FROM asset_registry a
            JOIN inventory_items i ON a.item_id = i.id
            WHERE i.name ILIKE '%bed sheet%'
        """)
        assets = cur.fetchall()
        print("\nBed Sheet Assets:")
        for asset in assets:
            print(asset)

    except Exception as e:
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    check_laundry()
