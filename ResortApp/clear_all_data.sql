-- ========================================
-- COMPLETE DATA CLEANUP SCRIPT
-- Clears ALL transactional data
-- Keeps: Rooms, Categories, Vendors, Users
-- ========================================

BEGIN;

-- 1. BOOKING & CHECKOUT DATA
TRUNCATE TABLE booking_rooms CASCADE;
TRUNCATE TABLE bookings CASCADE;
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE service_charges CASCADE;

-- 2. INVENTORY TRANSACTIONS & STOCK
TRUNCATE TABLE inventory_transactions CASCADE;
TRUNCATE TABLE location_stock CASCADE;
TRUNCATE TABLE purchase_details CASCADE;
TRUNCATE TABLE purchase_master CASCADE;
TRUNCATE TABLE stock_issue_details CASCADE;
TRUNCATE TABLE stock_issues CASCADE;
TRUNCATE TABLE stock_requisition_details CASCADE;
TRUNCATE TABLE stock_requisitions CASCADE;
TRUNCATE TABLE waste_logs CASCADE;

-- 3. ASSET MANAGEMENT
TRUNCATE TABLE asset_registry CASCADE;
TRUNCATE TABLE asset_mappings CASCADE;

-- 4. RECIPES & FOOD ORDERS
TRUNCATE TABLE recipe_ingredients CASCADE;
TRUNCATE TABLE recipes CASCADE;
TRUNCATE TABLE food_order_items CASCADE;
TRUNCATE TABLE food_orders CASCADE;

-- 5. SERVICE REQUESTS
TRUNCATE TABLE service_requests CASCADE;

-- 6. GST REPORTS & ACCOUNTING
TRUNCATE TABLE gst_reports CASCADE;
TRUNCATE TABLE journal_entries CASCADE;
TRUNCATE TABLE activity_logs CASCADE;

-- 7. EXPENSES
TRUNCATE TABLE expenses CASCADE;

-- 8. ATTENDANCE
TRUNCATE TABLE attendance CASCADE;

-- 9. RESET INVENTORY ITEM STOCK TO ZERO
UPDATE inventory_items SET current_stock = 0 WHERE 1=1;

-- 10. RESET ROOM STATUS
UPDATE rooms SET 
    status = 'Available',
    housekeeping_status = 'Clean',
    housekeeping_updated_at = NULL
WHERE 1=1;

COMMIT;

-- Verification Queries
SELECT 'Bookings' as table_name, COUNT(*) as count FROM bookings
UNION ALL
SELECT 'Payments', COUNT(*) FROM payments
UNION ALL
SELECT 'Inventory Transactions', COUNT(*) FROM inventory_transactions
UNION ALL
SELECT 'Location Stock', COUNT(*) FROM location_stock
UNION ALL
SELECT 'Purchase Master', COUNT(*) FROM purchase_master
UNION ALL
SELECT 'Stock Issues', COUNT(*) FROM stock_issues
UNION ALL
SELECT 'Waste Logs', COUNT(*) FROM waste_logs
UNION ALL
SELECT 'Asset Registry', COUNT(*) FROM asset_registry
UNION ALL
SELECT 'Recipes', COUNT(*) FROM recipes
UNION ALL
SELECT 'Food Orders', COUNT(*) FROM food_orders
UNION ALL
SELECT 'Service Requests', COUNT(*) FROM service_requests
UNION ALL
SELECT 'GST Reports', COUNT(*) FROM gst_reports
UNION ALL
SELECT 'Expenses', COUNT(*) FROM expenses;
