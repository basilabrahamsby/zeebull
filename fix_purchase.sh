#!/bin/bash

echo "Fixing Purchase Order PO-20260111-0001..."

# Execute SQL commands
sudo -u postgres psql orchid_resort <<'EOF'
-- Check current state
SELECT 'Current Purchase State:' as info;
SELECT id, purchase_number, total_amount FROM purchases WHERE purchase_number = 'PO-20260111-0001';

-- Update the purchase with proper amounts
-- Assuming the purchase exists and just needs the amounts fixed
UPDATE purchases 
SET 
    sub_total = 2000.00,
    cgst = 180.00,
    sgst = 180.00,
    total_amount = 2360.00,
    paid_amount = 2360.00,
    payment_status = 'paid'
WHERE purchase_number = 'PO-20260111-0001';

-- Verify
SELECT 'Updated Purchase State:' as info;
SELECT id, purchase_number, total_amount, paid_amount, payment_status FROM purchases WHERE purchase_number = 'PO-20260111-0001';
EOF

echo "Done!"
