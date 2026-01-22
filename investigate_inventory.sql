SELECT t.id, t.item_id, i.name, t.quantity, t.transaction_type 
FROM inventory_transactions t 
JOIN inventory_items i ON t.item_id = i.id 
WHERE t.reference_number = 'PO-20260117-0001';

SELECT id, name, current_stock, unit_price 
FROM inventory_items 
WHERE name IN ('chicken breast', 'Rice', 'oil', 'Mineral water', 'Coca Cola', 'soap', 'LED bulb', 'SMART TV');
