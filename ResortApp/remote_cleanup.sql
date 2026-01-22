-- Remote Server Cleanup Script for Orchiddb
-- Instructions: 
-- 1. Copy this file to the remote server
-- 2. Run: psql -U orchiduser -d orchiddb -f remote_cleanup.sql

BEGIN;

-- 1. Clear Transactional Tables
TRUNCATE TABLE 
    bookings,
    package_bookings,
    food_orders,
    purchase_masters,
    stock_issues,
    stock_requisitions,
    inventory_transactions,
    waste_logs,
    assigned_services,
    service_requests,
    checkouts,
    journal_entries,
    asset_mappings,
    asset_registry,
    activity_logs,
    notifications,
    payments,
    expenses
RESTART IDENTITY CASCADE;

-- 2. Reset Stock Counts
UPDATE inventory_items SET current_stock = 0;
UPDATE location_stocks SET quantity = 0;

-- 3. Reset Room Status
UPDATE rooms SET status = 'Available';

COMMIT;
