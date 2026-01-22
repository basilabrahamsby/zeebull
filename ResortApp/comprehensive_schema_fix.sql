-- Comprehensive Schema Fixes for Server

-- Fix Bookings Table
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS is_id_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS package_preferences TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS digital_signature_url VARCHAR;

-- Fix Rooms Table
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS housekeeping_status VARCHAR DEFAULT 'Clean';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS housekeeping_updated_at TIMESTAMP;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS last_maintenance_date DATE;

-- Fix Inventory Items Table
ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS track_laundry_cycle BOOLEAN DEFAULT FALSE;

-- Ensure Laundry Logs Table Exists
CREATE TABLE IF NOT EXISTS laundry_logs (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES inventory_items(id),
    source_location_id INTEGER REFERENCES locations(id),
    room_number VARCHAR,
    quantity FLOAT NOT NULL,
    status VARCHAR NOT NULL DEFAULT 'Incomplete Washing',
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    washed_at TIMESTAMP,
    returned_at TIMESTAMP,
    created_by INTEGER REFERENCES users(id),
    notes TEXT
);

-- Ensure Laundry Location Exists
INSERT INTO locations (name, location_type, building, is_inventory_point)
SELECT 'Laundry', 'LAUNDRY', 'Main', true
WHERE NOT EXISTS (SELECT 1 FROM locations WHERE location_type = 'LAUNDRY');
