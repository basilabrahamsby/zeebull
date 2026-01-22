-- 1. Correct the LocationStock for LED bulb (item_id 2) in Main Warehouse (location_id 1) to 6
UPDATE location_stocks SET quantity = 6 WHERE location_id = 1 AND item_id = 2;

-- 2. Log 1 LED bulb as waste (Damaged rentable asset)
-- We'll use location 1 (as it was returned/accounted there or as requested) or location 4 (Room 101) where it happened.
-- User said "one rentable asset was damaged", previously I deleted WASTE-20260111-001.
-- Let's create a new waste log.

INSERT INTO waste_logs (
    log_number, item_id, location_id, quantity, unit, 
    reason_code, action_taken, reported_by, waste_date, created_at, is_food_item
) VALUES (
    'WASTE-LED-FIX-001', 2, 4, 1, 'pcs', 
    'Damaged', 'Charged to Guest', 1, NOW(), NOW(), false
);

-- 3. Update global current_stock for item 2
-- 6 (Warehouse) + 3 (Rooms) = 9 active units.
UPDATE inventory_items SET current_stock = 9 WHERE id = 2;

-- 4. Verify transaction history for consistency
INSERT INTO inventory_transactions (
    item_id, transaction_type, quantity, unit_price, total_amount, 
    reference_number, notes, created_by, created_at
) VALUES (
    2, 'waste_spoilage', 1, 50, 50, 
    'WASTE-LED-FIX-001', 'Damaged rentable LED bulb during checkout', 1, NOW()
);
