-- Create Laundry Logs table if not exists
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

-- Ensure inventory_items has 'track_laundry_cycle'
ALTER TABLE inventory_items ADD COLUMN IF NOT EXISTS track_laundry_cycle BOOLEAN DEFAULT FALSE;

-- Ensure inventory_categories has 'is_asset_fixed' (implied in logic)
ALTER TABLE inventory_categories ADD COLUMN IF NOT EXISTS is_asset_fixed BOOLEAN DEFAULT FALSE;

-- Ensure locations has 'location_type'
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'location_type_enum') THEN
        -- Create enum if needed, or just ensure column exists as text/varchar
        -- Assuming it is VARCHAR for now based on code usage
        NULL;
    END IF;
END $$;

-- Make sure Laundry location exists
INSERT INTO locations (name, location_type, building, is_inventory_point)
SELECT 'Laundry', 'LAUNDRY', 'Main', true
WHERE NOT EXISTS (SELECT 1 FROM locations WHERE location_type = 'LAUNDRY');
