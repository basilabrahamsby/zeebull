import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load env
load_dotenv("c:\\releasing\\New Orchid\\ResortApp\\.env")
db_url = os.getenv("DATABASE_URL")

print(f"Connecting to database: {db_url}")
engine = create_engine(db_url)

with engine.connect() as conn:
    # 1. Discover foreign key constraints pointing to bookings table
    fk_query = """
        SELECT
            tc.table_name, 
            kcu.column_name, 
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name 
        FROM 
            information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
              AND tc.table_schema = kcu.table_schema
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
              AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY' AND ccu.table_name='bookings';
    """
    
    print("\n--- Discovering Foreign Key Dependencies for table 'bookings' ---")
    dependencies = conn.execute(text(fk_query)).fetchall()
    for dep in dependencies:
        print(f"Table: {dep.table_name} | Column: {dep.column_name} references bookings.{dep.foreign_column_name}")

    # 2. Find duplicates
    duplicate_query = """
        SELECT external_id, COUNT(*), string_agg(id::text, ', ') as ids, string_agg(display_id, ', ') as displays
        FROM bookings
        WHERE external_id IS NOT NULL AND external_id != ''
        GROUP BY external_id
        HAVING COUNT(*) > 1;
    """
    
    duplicates = conn.execute(text(duplicate_query)).fetchall()
    print(f"\n--- Duplicate external_ids found: {len(duplicates)} ---")
    
    # 3. Perform cleanup safely
    # For each duplicate group, we want to keep the FIRST booking (earliest created_at/id)
    # and delete subsequent ones. If there are dependent rows, we must clean/re-link them or delete them if safe.
    for ext_id, count, ids_str, displays_str in duplicates:
        booking_ids = [int(i) for i in ids_str.split(", ")]
        booking_ids.sort() # Ensure ascending order (earliest first)
        
        keep_id = booking_ids[0]
        delete_ids = booking_ids[1:]
        
        print(f"\nProcessing External ID: {ext_id}")
        print(f"  Keeping: ID {keep_id} (Display ID: {conn.execute(text('SELECT display_id FROM bookings WHERE id = :id'), {'id': keep_id}).scalar()})")
        print(f"  Deleting duplicates: {delete_ids}")
        
        # Clean up or delete dependent tables for deleted duplicate bookings
        for dep in dependencies:
            dep_table = dep.table_name
            dep_col = dep.column_name
            
            # Check if there are any dependent rows
            check_dep = conn.execute(text(f"SELECT COUNT(*) FROM {dep_table} WHERE {dep_col} IN :delete_ids"), {"delete_ids": tuple(delete_ids)}).scalar()
            if check_dep > 0:
                print(f"    Found {check_dep} rows in '{dep_table}' referencing duplicate booking IDs {delete_ids}")
                
                # If they can be re-linked to the kept booking ID, let's re-link them!
                # For booking_rooms, since the guest is only assigned to one physical room configuration, let's see.
                # Actually, re-linking is safer or deleting if they are redundant duplicate rooms. Let's see:
                if dep_table == "booking_rooms":
                    # Delete the duplicate booking_room links since they are duplicates of the kept one
                    del_stmt = f"DELETE FROM {dep_table} WHERE {dep_col} IN :delete_ids"
                    print(f"    Executing: {del_stmt}")
                    conn.execute(text(del_stmt), {"delete_ids": tuple(delete_ids)})
                else:
                    # Update/re-link to keep_id
                    upd_stmt = f"UPDATE {dep_table} SET {dep_col} = :keep_id WHERE {dep_col} IN :delete_ids"
                    print(f"    Executing: {upd_stmt}")
                    conn.execute(text(upd_stmt), {"keep_id": keep_id, "delete_ids": tuple(delete_ids)})
                    
        # Now delete the duplicate bookings themselves
        del_booking_stmt = "DELETE FROM bookings WHERE id IN :delete_ids"
        conn.execute(text(del_booking_stmt), {"delete_ids": tuple(delete_ids)})
        print(f"  Successfully deleted bookings with IDs {delete_ids}")
        
    # Commit changes
    conn.execute(text("COMMIT;"))
    print("\nDatabase cleanup committed successfully!")
