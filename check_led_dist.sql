SELECT location_id, count(id) FROM asset_mappings WHERE item_id = 2 AND is_active = true GROUP BY location_id;
SELECT location_id, quantity FROM location_stocks WHERE item_id = 2;
SELECT name, id FROM locations WHERE id IN (SELECT location_id FROM asset_mappings WHERE item_id = 2 AND is_active = true);
