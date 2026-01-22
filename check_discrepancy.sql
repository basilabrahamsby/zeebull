SELECT 
    i.id, 
    i.name, 
    i.current_stock, 
    pd.quantity as po_quantity,
    ls.quantity as location_stock
FROM purchase_details pd
JOIN purchase_masters pm ON pd.purchase_master_id = pm.id
JOIN inventory_items i ON pd.item_id = i.id
LEFT JOIN location_stocks ls ON ls.item_id = i.id AND ls.location_id = pm.destination_location_id
WHERE pm.purchase_number = 'PO-20260117-0001';
