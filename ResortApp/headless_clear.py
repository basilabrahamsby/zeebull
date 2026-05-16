
from sqlalchemy import text
from app.database import SessionLocal
from datetime import datetime

def clear_transactions():
    """Clear all transactional data but keep master data"""
    db = SessionLocal()
    
    try:
        print("=" * 60)
        print("CLEAR TRANSACTIONS ONLY - HEADLESS V2")
        print("=" * 60)
        print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        # Delete in correct order to avoid foreign key constraints
        # We clear finance and dependent records FIRST
        tables = [
            # Finance
            "journal_entry_lines",
            "journal_entries",
            "payments",
            "expenses",
            "night_charges",
            
            # Checkout
            "checkout_payments",
            "checkout_verifications",
            "checkout_requests",
            "checkouts",
            
            # Services & Food
            "assigned_services",
            "service_requests",
            "food_order_items",
            "food_orders",
            
            # Bookings
            "package_booking_rooms",
            "booking_rooms",
            "package_bookings",
            "bookings",
            
            # Inventory Transactions
            "inventory_transactions",
            "stock_issue_details",
            "stock_requisition_details",
            "purchase_details",
            "stock_issues",
            "stock_requisitions",
            "purchase_masters",
            "location_stocks",
            "waste_logs",
            
            # Misc
            "notifications",
            "suggestions",
            "working_logs",
            "attendance",
            "employee_inventory_assignments",
            "asset_registry",
            "asset_mappings",
        ]
        
        print("-" * 60)
        print("CLEARING TABLES")
        print("-" * 60)
        
        # Disable FK checks for the duration of this session if possible, 
        # but DELETE in order is better. 
        # Alternatively, use a single transaction.
        
        for table in tables:
            try:
                check_query = text(f"SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '{table}')")
                exists = db.execute(check_query).scalar()
                
                if exists:
                    result = db.execute(text(f"DELETE FROM {table}"))
                    if result.rowcount > 0:
                        print(f"Cleared {result.rowcount:4d} from {table}")
                    db.commit()
                else:
                    # print(f"Table {table} not found (skipped)")
                    pass
            except Exception as e:
                db.rollback()
                print(f"Error clearing {table}: {str(e)[:100]}")

        print("-" * 60)
        print("RESETTING VALUES")
        print("-" * 60)
        
        # Reset Room Status
        try:
            result = db.execute(text("UPDATE rooms SET status = 'Available'"))
            db.commit()
            print(f"Reset {result.rowcount} rooms to 'Available'")
        except Exception as e:
            print(f"Error resetting rooms: {str(e)}")
            
        # Reset Inventory Stock Counts
        try:
            result = db.execute(text("UPDATE inventory_items SET current_stock = 0"))
            db.commit()
            print(f"Reset stock count to 0 for {result.rowcount} inventory items")
        except Exception as e:
            print(f"Error resetting inventory stock: {str(e)}")

        print("\n" + "=" * 60)
        print("TRANSACTION CLEANUP COMPLETED")
        print("=" * 60)
        
    except Exception as e:
        db.rollback()
        print(f"\nFATAL ERROR: {str(e)}")
    finally:
        db.close()

if __name__ == "__main__":
    clear_transactions()
