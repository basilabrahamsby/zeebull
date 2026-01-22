-- DYNAMIC CLEANUP SCRIPT
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        AND tablename NOT IN (
            'users', 
            'roles', 
            'inventory_items', 
            'inventory_categories', 
            'food_categories', 
            'vendors', 
            'units',
            'alembic_version' -- keep migration info
        )
    ) LOOP
        EXECUTE 'TRUNCATE TABLE ' || quote_ident(r.tablename) || ' RESTART IDENTITY CASCADE';
        RAISE NOTICE 'Truncated table: %', r.tablename;
    END LOOP;
END $$;

-- Reset master data stock if needed
UPDATE inventory_items SET current_stock = 0;
