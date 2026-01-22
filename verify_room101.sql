SELECT log_number, i.name, notes FROM waste_logs w JOIN inventory_items i ON w.item_id = i.id WHERE w.notes ILIKE '%Room 101%';
