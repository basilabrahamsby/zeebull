\echo 'Asset Registry Damaged'
SELECT id, item_id, status FROM asset_registry WHERE status = 'damaged';
\echo 'Stock Issue Details Damaged'
SELECT id, item_id, is_damaged FROM stock_issue_details WHERE is_damaged = true;
