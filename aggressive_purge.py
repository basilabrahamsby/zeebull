
import sys
import os

# Add the app directory to sys.path
sys.path.append('/var/www/inventory/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

# Expanded list of tables to clear based on the dashboard image
# The image shows Revenue, Net Profit, Sellable Items, etc. still populated.
TABLES_TO_CLEAR = [
    # -- Activity & Logs --
    "activity_logs",
    "notifications",
    "working_logs",
    "waste_logs",
    "wastage_logs",
    
    # -- Guest Operations --
    "bookings",
    "booking_rooms",
    "package_bookings",
    "package_booking_rooms",
    "checkouts",
    "checkout_payments",
    "checkout_verification",
    "checkout_requests",
    "service_requests",
    "food_orders",
    "food_order_items",
    "guest_suggestions",
    "reviews",
    "lost_found",
    
    # -- Inventory & Stock --
    "inventory_transactions",
    "stock_issues",
    "stock_issue_details",
    "stock_requisitions",
    "stock_requisition_details",
    "stock_movements",
    "stock_usage",
    "stock_levels",
    "location_stocks",
    "outlet_stocks",
    "linen_stocks",
    "room_consumable_assignments",
    "room_inventory_audits",
    
    # -- Purchasing --
    "purchase_masters",
    "purchase_details",
    "purchase_orders",
    "po_items",
    "purchase_entries",
    "purchase_entry_items",
    "goods_received_notes",
    "grn_items",
    "indent_items",
    "indents",
    "vendor_items", # Might be linked to cached revenue calc?
    
    # -- Financials & Accounting --
    "expenses",
    "inventory_expenses",
    "payments",
    "vouchers",
    "journal_entries",
    "journal_entry_lines",
    "accounting_ledgers",
    "eod_audits",
    "eod_audit_items",
    
    # -- Maintenance & Operations --
    "maintenance_tickets",
    "work_orders",
    "work_order_parts",
    "work_order_part_issues",
    "laundry_services",
    "linen_movements",
    "linen_wash_logs",
    "key_movements",
    
    # -- Safety & Alerts --
    "fire_safety_incidents",
    "fire_safety_inspections",
    "fire_safety_maintenance",
    "security_maintenance",
    "restock_alerts",
    "expiry_alerts",
    "perishable_batches"
]

def force_clear_data():
    db = SessionLocal()
    try:
        print("=== COMMENCING AGGRESSIVE DATA PURGE ===")
        
        # 1. Clear Tables with Cascade
        for table in TABLES_TO_CLEAR:
            print(f"  - Purging {table}...")
            try:
                # Use TRUNCATE ... CASCADE to ensure all dependent rows are also removed
                db.execute(text(f'TRUNCATE TABLE "{table}" RESTART IDENTITY CASCADE'))
            except Exception as e:
                # If table doesn't exist or other error, log and continue
                if "does not exist" not in str(e):
                    print(f"    Warning: Issue with {table}: {e}")
                db.rollback()
                continue
            db.commit() # Commit after each successful truncate
            
        # 2. Reset Statuses (Vital for Dashboard "Available Rooms")
        print("\n=== RESETTING ENTITY STATUSES ===")
        
        print("  - Resetting ALL Rooms to 'Available' & Clean...")
        db.execute(text("UPDATE rooms SET status = 'Available', is_clean = true, housekeeping_status = 'Clean'"))
        
        print("  - Resetting Inventory Item stock counts to 0...")
        db.execute(text("UPDATE inventory_items SET current_stock = 0.0, total_value = 0.0"))
        
        print("  - Resetting Employee status (optional cleanup)...")
        # Keep employees active, just ensure no dangling states?
        # db.execute(text("UPDATE employees SET current_task = NULL"))

        db.commit()
        print("\n=== PURGE COMPLETE ===")
        print("Dashboard stats should now reflect ZERO.")
        
    except Exception as e:
        db.rollback()
        print(f"\n[CRITICAL ERROR] Purge Failed: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    force_clear_data()
