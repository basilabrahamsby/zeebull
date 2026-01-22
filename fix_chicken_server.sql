UPDATE inventory_items SET current_stock = 10 WHERE id = 1;
UPDATE location_stocks SET quantity = 10 WHERE item_id = 1 AND location_id = 1;
DELETE FROM inventory_transactions WHERE item_id = 1 AND reference_number = 'PO-20260117-0001' AND id NOT IN (SELECT MIN(id) FROM inventory_transactions WHERE item_id = 1 AND reference_number = 'PO-20260117-0001');
