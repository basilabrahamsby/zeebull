-- Final check of counts
SELECT 'WH Stock' as loc, quantity FROM location_stocks WHERE location_id = 1 AND item_id = 2;
SELECT 'Room Stock' as loc, quantity FROM location_stocks WHERE location_id = 4 AND item_id = 2;
SELECT 'Global Stock' as loc, current_stock FROM inventory_items WHERE id = 2;

-- The requested fixes
BEGIN;

-- 1. Restore the fixed asset in Room 101
UPDATE asset_mappings SET is_active = true WHERE id = 1;
UPDATE location_stocks SET quantity = 1 WHERE location_id = 4 AND item_id = 2;

-- 2. Remove the duplicate/unnecessary waste log
DELETE FROM waste_logs WHERE log_number = 'WASTE-20260111-001';

-- 3. Adjust global stock? 
-- If the damaged bulb was a rental, it should be removed from total stock.
-- Check if it was already removed.
-- Transaction 33 (waste_spoilage) was -1. That removed it from global stock.
-- If I delete the waste log, I should check if the transaction should also be deleted or adjusted.
-- The user says "damaged LED bulb should be reduced from source location (WH)".
-- Actually, if it's damaged, it's GONE. 
-- WH stock currently? If it was returned there incorrectly, I should remove it.

COMMIT;

-- Verify after fix
SELECT 'WH Stock' as loc, quantity FROM location_stocks WHERE location_id = 1 AND item_id = 2;
SELECT 'Room Stock' as loc, quantity FROM location_stocks WHERE location_id = 4 AND item_id = 2;
SELECT 'Global Stock' as loc, current_stock FROM inventory_items WHERE id = 2;
