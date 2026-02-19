import psycopg2
import sys

def cleanup():
    # Use sudo -u postgres on server or correct user/pass
    # Here we'll try to connect as postgres locally on server via sudo
    try:
        conn = psycopg2.connect(dbname="orchid_resort", user="postgres")
        cur = conn.cursor()
        log_numbers = ('WASTE-20260219-001', 'WASTE-20260219-002')
        
        # 1. Get transaction info
        cur.execute("SELECT item_id, quantity, reference_number FROM inventory_transactions WHERE reference_number IN %s", (log_numbers,))
        txns = cur.fetchall()
        
        if not txns:
            print("No transactions found with these log numbers.")
            return

        for item_id, qty, ref in txns:
            print(f"Reverting transaction {ref} for item {item_id} (qty: {qty})")
            
            # Restore global stock
            cur.execute("UPDATE inventory_items SET current_stock = current_stock + %s WHERE id = %s", (qty, item_id))
            
        # 2. Delete transactions
        cur.execute("DELETE FROM inventory_transactions WHERE reference_number IN %s", (log_numbers,))
        print(f"Deleted {cur.rowcount} transactions from inventory_transactions.")
        
        # 3. Delete waste logs
        cur.execute("DELETE FROM waste_logs WHERE log_number IN %s", (log_numbers,))
        print(f"Deleted {cur.rowcount} waste logs.")
        
        # 4. Fix Asset Status
        for item_id, qty, ref in txns:
             cur.execute("UPDATE asset_registry SET status = 'active' WHERE item_id = %s AND status = 'damaged'", (item_id,))
             if cur.rowcount > 0:
                 print(f"Restored status to active for assets of item {item_id}")

        conn.commit()
        print("Cleanup complete.")
    except Exception as e:
        if 'conn' in locals(): conn.rollback()
        print(f"Error: {e}")
    finally:
        if 'cur' in locals(): cur.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    cleanup()
