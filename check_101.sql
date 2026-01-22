SELECT id, number, inventory_location_id FROM rooms WHERE number = '101';
SELECT id, item_id, status, is_damaged FROM asset_registry WHERE current_location_id = (SELECT inventory_location_id FROM rooms WHERE number = '101');
SELECT id, item_id, is_damaged FROM stock_issue_details WHERE destination_location_id = (SELECT inventory_location_id FROM rooms WHERE number = '101');
