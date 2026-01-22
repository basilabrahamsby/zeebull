-- Fix Purchase Order PO-20260111-0001
-- This script will update the purchase order with sample data

-- First, let's check what's in the purchase
SELECT id, purchase_number, vendor_id, total_amount, sub_total, status 
FROM purchases 
WHERE purchase_number = 'PO-20260111-0001';

-- Check if there are any details
SELECT pd.id, pd.purchase_id, pd.item_id, pd.quantity, pd.unit_price, pd.total_amount
FROM purchase_details pd
JOIN purchases p ON pd.purchase_id = p.id
WHERE p.purchase_number = 'PO-20260111-0001';

-- If no details exist, we need to add them
-- Let's add some sample items (adjust item_ids based on your actual inventory)

-- Example: Add 2 items to the purchase
-- Replace item_ids (1, 2) with actual item IDs from your inventory_items table

-- First, get the purchase ID
DO $$
DECLARE
    v_purchase_id INT;
    v_item1_id INT;
    v_item2_id INT;
BEGIN
    -- Get purchase ID
    SELECT id INTO v_purchase_id FROM purchases WHERE purchase_number = 'PO-20260111-0001';
    
    -- Get some actual item IDs (first 2 items from inventory)
    SELECT id INTO v_item1_id FROM inventory_items WHERE is_active = true LIMIT 1;
    SELECT id INTO v_item2_id FROM inventory_items WHERE is_active = true OFFSET 1 LIMIT 1;
    
    -- Delete existing details (if any)
    DELETE FROM purchase_details WHERE purchase_id = v_purchase_id;
    
    -- Add Item 1: 10 units @ ₹100 each
    INSERT INTO purchase_details (
        purchase_id, item_id, quantity, unit, unit_price, gst_rate,
        cgst_amount, sgst_amount, igst_amount, discount, total_amount
    ) VALUES (
        v_purchase_id, v_item1_id, 10, 'pcs', 100.00, 18.00,
        90.00, 90.00, 0.00, 0.00, 1180.00
    );
    
    -- Add Item 2: 5 units @ ₹200 each
    INSERT INTO purchase_details (
        purchase_id, item_id, quantity, unit, unit_price, gst_rate,
        cgst_amount, sgst_amount, igst_amount, discount, total_amount
    ) VALUES (
        v_purchase_id, v_item2_id, 5, 'pcs', 200.00, 18.00,
        90.00, 90.00, 0.00, 0.00, 1180.00
    );
    
    -- Update purchase master totals
    -- Item 1: 10 * 100 = 1000, GST 18% = 180 (CGST 90 + SGST 90), Total = 1180
    -- Item 2: 5 * 200 = 1000, GST 18% = 180 (CGST 90 + SGST 90), Total = 1180
    -- Grand Total: 2000 + 360 = 2360
    UPDATE purchases 
    SET 
        sub_total = 2000.00,
        cgst = 180.00,
        sgst = 180.00,
        igst = 0.00,
        discount = 0.00,
        total_amount = 2360.00
    WHERE id = v_purchase_id;
    
    RAISE NOTICE 'Purchase order updated successfully!';
END $$;

-- Verify the update
SELECT id, purchase_number, vendor_id, total_amount, sub_total, cgst, sgst, status 
FROM purchases 
WHERE purchase_number = 'PO-20260111-0001';

SELECT pd.id, pd.item_id, ii.name as item_name, pd.quantity, pd.unit_price, pd.total_amount
FROM purchase_details pd
JOIN purchases p ON pd.purchase_id = p.id
JOIN inventory_items ii ON pd.item_id = ii.id
WHERE p.purchase_number = 'PO-20260111-0001';
