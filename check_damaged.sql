SELECT id, item_id, status, current_location_id FROM asset_registry WHERE status = 'damaged';
SELECT id, item_id, is_damaged, rental_price FROM stock_issue_details WHERE is_damaged = true;
