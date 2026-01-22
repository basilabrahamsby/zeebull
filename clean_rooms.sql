-- Clean Rooms and Dependencies
DELETE FROM employee_inventory_assignments;
DELETE FROM assigned_services;
DELETE FROM location_stocks;
DELETE FROM rooms;
DELETE FROM locations WHERE location_type = 'GUEST_ROOM';
