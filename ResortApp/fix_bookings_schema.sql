-- Fix Bookings Schema
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS is_id_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS package_preferences TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS digital_signature_url VARCHAR;
