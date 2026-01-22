\x
-- Find location ID for Room 101
SELECT id, inventory_location_id FROM rooms WHERE number = '101';

-- Get LocationStock
SELECT ls.location_id, ls.item_id, ls.quantity, i.name 
FROM location_stocks ls 
JOIN inventory_items i ON ls.item_id = i.id 
WHERE ls.location_id IN (SELECT inventory_location_id FROM rooms WHERE number = '101');

-- Get AssetRegistry
SELECT ar.id, ar.item_id, ar.status, ar.serial_number, i.name 
FROM asset_registry ar 
JOIN inventory_items i ON ar.item_id = i.id 
WHERE ar.current_location_id IN (SELECT inventory_location_id FROM rooms WHERE number = '101');

-- Get AssetMappings
SELECT am.id, am.item_id, am.quantity, am.is_active, i.name 
FROM asset_mappings am 
JOIN inventory_items i ON am.item_id = i.id 
WHERE am.location_id IN (SELECT inventory_location_id FROM rooms WHERE number = '101');
