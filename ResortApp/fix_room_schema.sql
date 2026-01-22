-- Fix Room Schema
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS housekeeping_status VARCHAR DEFAULT 'Clean';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS housekeeping_updated_at TIMESTAMP;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS last_maintenance_date DATE;
