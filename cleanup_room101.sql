-- Deactivate asset mappings for damaged items in Room 101 (Location 4)
UPDATE asset_mappings 
SET is_active = false 
WHERE location_id = 4 AND item_id IN (2, 3);

-- Verify
SELECT id, item_id, is_active FROM asset_mappings WHERE location_id = 4;
