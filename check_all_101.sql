SELECT id, requested_at, inventory_data FROM checkout_requests WHERE room_number = '101' AND status = 'completed' ORDER BY id DESC;
