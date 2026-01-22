
import sys
import os

# Add the app directory to sys.path
sys.path.append('/var/www/inventory/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

TABLES_TO_CLEAR = [
    "activity_logs",
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
    "purchase_masters",
    "purchase_details",
    "purchase_orders",
    "po_items",
    "purchase_entries",
    "purchase_entry_items",
    "goods_received_notes",
    "grn_items",
    "wastage_logs",
    "waste_logs",
    "expenses",
    "inventory_expenses",
    "notifications",
    "working_logs",
    "maintenance_tickets",
    "work_orders",
    "work_order_parts",
    "work_order_part_issues",
    "lost_found",
    "laundry_services",
    "linen_movements",
    "linen_wash_logs",
    "room_consumable_assignments",
    "room_inventory_audits",
    "journal_entries",
    "journal_entry_lines",
    "vouchers",
    "payments",
    "key_movements",
    "guest_suggestions",
    "fire_safety_incidents",
    "fire_safety_inspections",
    "fire_safety_maintenance",
    "security_maintenance",
    "security_uniforms",
    "restock_alerts",
    "expiry_alerts",
    "eod_audits",
    "eod_audit_items",
    "perishable_batches",
    "indent_items",
    "indents",
    "accounting_ledgers"
]

def clear_data():
    db = SessionLocal()
    try:
        print("=== DELETING OPERATIONAL DATA ===")
        # Disable triggers/constraints to speed up or handle dependencies? 
        # TRUNCATE with CASCADE is usually enough in Postgres
        
        for table in TABLES_TO_CLEAR:
            print(f"  - Clearing {table}...")
            try:
                db.execute(text(f'TRUNCATE TABLE "{table}" RESTART IDENTITY CASCADE'))
            except Exception as e:
                print(f"    Warning: Could not clear {table}: {e}")
                db.rollback()
                continue
        
        # Reset specific statuses
        print("\n=== RESETTING MASTER DATA STATUSES ===")
        print("  - Resetting Room status to 'Available'...")
        db.execute(text("UPDATE rooms SET status = 'Available'"))
        
        print("  - Resetting Inventory Item stock to 0...")
        db.execute(text("UPDATE inventory_items SET current_stock = 0.0"))
        
        db.commit()
        print("\n=== SYSTEM DATA CLEARED SUCCESSFULLY ===")
        print("(Users, Roles, Rooms, Employees, Vendors, etc. were preserved)")
        
    except Exception as e:
        db.rollback()
        print(f"\n[ERROR] Cleanup Failed: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    clear_data()
