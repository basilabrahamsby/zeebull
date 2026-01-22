#!/bin/bash
# Check room status in database
echo "=== Checking Room Status in Database ==="
sudo -u postgres psql orchid_resort -c "SELECT number, status, housekeeping_status FROM rooms WHERE number IN ('101', '102', '103') ORDER BY number;"

echo ""
echo "=== Checking Purchase Orders for Sharma Vendor ==="
sudo -u postgres psql orchid_resort -c "SELECT p.id, p.purchase_number, p.total_amount, p.paid_amount, p.payment_status, p.status, v.name FROM purchases p JOIN vendors v ON p.vendor_id = v.id WHERE LOWER(v.name) LIKE '%sharma%' ORDER BY p.id DESC LIMIT 5;"

echo ""
echo "=== Checking Location Stock for Main Warehouse ==="
sudo -u postgres psql orchid_resort -c "SELECT l.name, COUNT(ls.id) as item_count, SUM(ls.quantity) as total_qty FROM locations l LEFT JOIN location_stocks ls ON l.id = ls.location_id WHERE l.name ILIKE '%warehouse%' GROUP BY l.id, l.name;"
