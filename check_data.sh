#!/bin/bash

echo "=== CHECKING PURCHASE ORDER DATA ==="
sudo -u postgres psql orchid_resort -c "SELECT id, purchase_number, vendor_id, total_amount, payment_status FROM purchases WHERE vendor_id = 2 ORDER BY id DESC LIMIT 3;"

echo ""
echo "=== CHECKING PURCHASE DETAILS ==="
sudo -u postgres psql orchid_resort -c "SELECT pd.id, pd.purchase_id, pd.item_id, ii.name as item_name, pd.quantity, pd.unit_price, pd.total_price FROM purchase_details pd JOIN inventory_items ii ON pd.item_id = ii.id WHERE pd.purchase_id IN (SELECT id FROM purchases WHERE vendor_id = 2) LIMIT 5;"

echo ""
echo "=== CHECKING ROOM STATUS ==="
sudo -u postgres psql orchid_resort -c "SELECT id, CAST(number AS TEXT) as room_num, status, housekeeping_status FROM rooms WHERE CAST(number AS TEXT) IN ('101', '102', '103');"

echo ""
echo "=== CHECKING BOOKINGS FOR ROOM 101 ==="
sudo -u postgres psql orchid_resort -c "SELECT b.id, b.guest_name, b.status, b.check_in, b.check_out, br.room_id FROM bookings b JOIN booking_rooms br ON b.id = br.booking_id JOIN rooms r ON br.room_id = r.id WHERE CAST(r.number AS TEXT) = '101' ORDER BY b.id DESC LIMIT 3;"
