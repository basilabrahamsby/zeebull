SELECT i.id, i.name, i.current_stock, ls.location_id, l.name as loc_name, ls.quantity 
FROM inventory_items i 
JOIN location_stocks ls ON i.id = ls.item_id 
JOIN locations l ON ls.location_id = l.id 
WHERE i.name ILIKE '%chicken%';
