-- State of LED bulb (Item 2) in Room 101 (Loc 4)
SELECT * FROM location_stocks WHERE location_id = 4 AND item_id = 2;
SELECT * FROM asset_mappings WHERE location_id = 4 AND item_id = 2;
SELECT * FROM asset_registry WHERE current_location_id = 4 AND item_id = 2;

-- Transactions for LED bulb
SELECT * FROM inventory_transactions WHERE item_id = 2 ORDER BY created_at DESC LIMIT 10;

-- Waste logs for LED bulb
SELECT * FROM waste_logs WHERE item_id = 2 ORDER BY waste_date DESC LIMIT 5;

-- Check stock issues for LED bulb to Room 101
SELECT sid.*, si.source_location_id, si.issue_date 
FROM stock_issue_details sid 
JOIN stock_issues si ON sid.issue_id = si.id 
WHERE sid.item_id = 2 AND si.destination_location_id = 4;
