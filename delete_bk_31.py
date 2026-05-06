import psycopg2

def run_deletion(booking_id):
    conn = None
    try:
        conn = psycopg2.connect("postgresql://postgres:qwerty123@localhost:5432/zeebuldb")
        cur = conn.cursor()
        
        print(f"Starting deletion for Booking ID: {booking_id}")
        
        # Get rooms first
        cur.execute("SELECT room_id FROM booking_rooms WHERE booking_id = %s", (booking_id,))
        room_ids = [r[0] for r in cur.fetchall()]
        print(f"Rooms to free up: {room_ids}")
        
        # 1. Checkout Requests
        cur.execute("DELETE FROM checkout_requests WHERE booking_id = %s", (booking_id,))
        print(f"Deleted {cur.rowcount} checkout requests")
        
        # 2. Checkouts (and its sub-tables)
        cur.execute("SELECT id FROM checkouts WHERE booking_id = %s", (booking_id,))
        checkout_ids = [c[0] for c in cur.fetchall()]
        if checkout_ids:
            cur.execute("DELETE FROM checkout_verifications WHERE checkout_id IN %s", (tuple(checkout_ids),))
            cur.execute("DELETE FROM checkout_payments WHERE checkout_id IN %s", (tuple(checkout_ids),))
            cur.execute("DELETE FROM checkouts WHERE id IN %s", (tuple(checkout_ids),))
            print(f"Deleted {len(checkout_ids)} checkouts and their verifications/payments")
        
        # 3. Payments
        cur.execute("DELETE FROM payments WHERE booking_id = %s", (booking_id,))
        print(f"Deleted {cur.rowcount} payments")
        
        # 4. Food Orders & Service Requests
        cur.execute("SELECT id FROM food_orders WHERE booking_id = %s", (booking_id,))
        order_ids = [o[0] for o in cur.fetchall()]
        if order_ids:
            cur.execute("DELETE FROM service_requests WHERE food_order_id IN %s", (tuple(order_ids),))
            print(f"Deleted {cur.rowcount} service requests linked to food orders")
            cur.execute("DELETE FROM food_order_items WHERE order_id IN %s", (tuple(order_ids),))
            cur.execute("DELETE FROM food_orders WHERE id IN %s", (tuple(order_ids),))
            print(f"Deleted {len(order_ids)} food orders and their items")
            
        # 5. Stock Issues
        cur.execute("SELECT id FROM stock_issues WHERE booking_id = %s", (booking_id,))
        issue_ids = [i[0] for i in cur.fetchall()]
        if issue_ids:
            cur.execute("DELETE FROM stock_issue_details WHERE issue_id IN %s", (tuple(issue_ids),))
            cur.execute("DELETE FROM stock_issues WHERE id IN %s", (tuple(issue_ids),))
            print(f"Deleted {len(issue_ids)} stock issues and their details")
            
        # 6. Booking Rooms
        cur.execute("DELETE FROM booking_rooms WHERE booking_id = %s", (booking_id,))
        print(f"Deleted {cur.rowcount} booking rooms")
        
        # 7. Booking
        cur.execute("DELETE FROM bookings WHERE id = %s", (booking_id,))
        print(f"Deleted {cur.rowcount} bookings")
        
        # 8. Free up rooms
        if room_ids:
            cur.execute("UPDATE rooms SET status = 'Available' WHERE id IN %s", (tuple(room_ids),))
            print(f"Updated {cur.rowcount} rooms to Available")
            
        conn.commit()
        print("TRANSACTION COMMITTED SUCCESSFULLY")
        
        cur.close()
        conn.close()
    except Exception as e:
        if conn:
            conn.rollback()
        print(f"ERROR: {e}")

if __name__ == "__main__":
    run_deletion(31)
