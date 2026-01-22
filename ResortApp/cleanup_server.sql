-- SERVER DATABASE CLEANUP (handles foreign keys)
\echo 'Starting comprehensive cleanup...'

-- Delete in correct order to respect foreign keys
DELETE FROM journal_entry_lines;
DELETE FROM journal_entries;
DELETE FROM checkout_requests;
DELETE FROM booking_rooms;
DELETE FROM bookings;
DELETE FROM payments;
DELETE FROM inventory_transactions;
DELETE FROM purchase_details;
DELETE FROM purchases;
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
DELETE FROM expenses;
DELETE FROM activity_logs;

-- Reset inventory stock
UPDATE inventory_items SET current_stock = 0;

-- Reset rooms (without housekeeping_status if column doesn't exist)
UPDATE rooms SET status = 'Available';

\echo 'Cleanup complete!'
\echo ''
\echo 'Verification:'
SELECT 'Bookings: ' || COUNT(*)::text FROM bookings
UNION ALL SELECT 'Payments: ' || COUNT(*)::text FROM payments
UNION ALL SELECT 'Inventory Txn: ' || COUNT(*)::text FROM inventory_transactions
UNION ALL SELECT 'Purchases: ' || COUNT(*)::text FROM purchases
UNION ALL SELECT 'Stock Issues: ' || COUNT(*)::text FROM stock_issues;
