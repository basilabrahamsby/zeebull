-- IMMEDIATE DATA CLEANUP - NO CONFIRMATION
-- Run this directly with psql

\echo '🔄 Starting data cleanup...'

-- Disable foreign key checks temporarily
SET session_replication_role = 'replica';

-- Clear all transactional data
DELETE FROM booking_rooms;
DELETE FROM bookings;
DELETE FROM payments;
DELETE FROM service_charges;
DELETE FROM inventory_transactions;
DELETE FROM location_stock;
DELETE FROM purchase_details;
DELETE FROM purchase_master;
DELETE FROM stock_issue_details;
DELETE FROM stock_issues;
DELETE FROM stock_requisition_details;
DELETE FROM stock_requisitions;
DELETE FROM waste_logs;
DELETE FROM asset_registry;
DELETE FROM asset_mappings;
DELETE FROM recipe_ingredients;
DELETE FROM recipes;
DELETE FROM food_order_items;
DELETE FROM food_orders;
DELETE FROM service_requests;
DELETE FROM gst_reports;
DELETE FROM journal_entries;
DELETE FROM activity_logs;
DELETE FROM expenses;
DELETE FROM attendance;

-- Reset inventory stock
UPDATE inventory_items SET current_stock = 0;

-- Reset rooms
UPDATE rooms SET status = 'Available', housekeeping_status = 'Clean', housekeeping_updated_at = NULL;

-- Re-enable foreign key checks
SET session_replication_role = 'origin';

\echo '✅ Data cleanup complete!'
\echo ''
\echo 'Verification:'
SELECT 'Bookings: ' || COUNT(*)::text FROM bookings
UNION ALL SELECT 'Payments: ' || COUNT(*)::text FROM payments
UNION ALL SELECT 'Inventory Txn: ' || COUNT(*)::text FROM inventory_transactions
UNION ALL SELECT 'Location Stock: ' || COUNT(*)::text FROM location_stock
UNION ALL SELECT 'Purchases: ' || COUNT(*)::text FROM purchase_master;
