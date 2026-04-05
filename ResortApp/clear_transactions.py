"""
clear_transactions.py
---------------------
Safely clears all transactional data:
  - Food Order Items & Food Orders
  - Service Requests
  - Checkout Payments, Checkout Verifications, Checkout Requests, Checkouts
  - Payments
  - Booking Rooms & Bookings
  - Package Bookings (child records)

Master data (Rooms, Packages, Users, Employees, Branches, etc.) is PRESERVED.

Usage:
  python clear_transactions.py            # dry-run (shows what will be deleted)
  python clear_transactions.py --confirm  # actually deletes
"""

import sys
import os
from dotenv import load_dotenv

# Load .env from the same directory as this script
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

from sqlalchemy import text
from app.database import engine

DRY_RUN = "--confirm" not in sys.argv

# Deletion order is critical: child tables must be deleted before parents
# to avoid foreign key constraint violations.
TABLES_IN_ORDER = [
    # --- Food ---
    "food_order_items",
    "food_orders",
    # --- Service ---
    "service_requests",
    # --- Checkout (children first) ---
    "checkout_payments",
    "checkout_verifications",
    "checkout_requests",
    "checkouts",
    # --- Payments ---
    "payments",
    # --- Bookings (children first) ---
    "booking_rooms",
    "bookings",
    # --- Package Bookings ---
    "package_bookings",
]


def get_counts(conn):
    counts = {}
    for table in TABLES_IN_ORDER:
        result = conn.execute(text(f"SELECT COUNT(*) FROM {table}"))
        counts[table] = result.scalar()
    return counts


def main():
    print("=" * 55)
    print("  TeqMates - Transaction Data Cleaner")
    print("=" * 55)

    if DRY_RUN:
        print("\n⚠️  DRY RUN MODE - Nothing will be deleted.")
        print("   Run with --confirm to actually delete.\n")
    else:
        print("\n🚨 LIVE MODE - Data WILL be permanently deleted!\n")

    with engine.connect() as conn:
        print("📊 Current record counts:\n")
        counts = get_counts(conn)
        total = 0
        for table, count in counts.items():
            print(f"   {table:<30} {count:>6} rows")
            total += count
        print(f"\n   {'TOTAL':<30} {total:>6} rows")

        if DRY_RUN:
            print("\n✅ Dry run complete. No changes made.")
            print("   Run with --confirm to delete all of the above.\n")
            return

        # Double-check before proceeding
        confirm = input("\n⚠️  Are you sure you want to delete ALL of the above? (yes/no): ").strip().lower()
        if confirm != "yes":
            print("\n❌ Aborted. No changes were made.\n")
            return

        print("\n🗑️  Deleting records...\n")
        for table in TABLES_IN_ORDER:
            try:
                result = conn.execute(text(f"DELETE FROM {table}"))
                print(f"   ✅ Cleared {table:<30} ({result.rowcount} rows deleted)")
            except Exception as e:
                print(f"   ❌ Failed to clear {table}: {e}")
                conn.rollback()
                print("\n   ⚠️  Rolling back all changes due to error.")
                return

        conn.commit()

        print("\n" + "=" * 55)
        print("  ✅ All transactional data cleared successfully!")
        print("=" * 55)
        print("\n   Master data (Rooms, Packages, Employees, Users,")
        print("   Branches, Roles) has been PRESERVED.\n")


if __name__ == "__main__":
    main()
