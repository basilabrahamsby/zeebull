#!/usr/bin/env python3
"""Check which tables reference the users or employees to find foreign key violations."""

import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from sqlalchemy import text

db = SessionLocal()

# Target User IDs: 4 (basil), 5 (alphi), 6 (appu), 22 (sanith)
user_ids = [4, 5, 6, 22]

# Let's find all employee IDs for these users
try:
    print("=== CHECKING USER AND EMPLOYEE REFERENCES ===")
    
    # Get employee IDs
    emp_res = db.execute(text("SELECT id, name, user_id FROM employees WHERE user_id IN (4, 5, 6, 22)")).all()
    emp_ids = [r[0] for r in emp_res]
    emp_map = {r[0]: r[1] for r in emp_res}
    print(f"Employee IDs to check: {emp_ids} ({emp_res})")

    # Let's inspect foreign keys from pg_catalog
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
    WHERE tc.constraint_type = 'FOREIGN KEY' 
      AND (ccu.table_name = 'users' OR ccu.table_name = 'employees');
    """
    fkeys = db.execute(text(fk_query)).all()
    
    for fk in fkeys:
        table_name = fk[0]
        col_name = fk[1]
        ref_table = fk[2]
        ref_col = fk[3]
        
        # Query references
        if ref_table == 'users':
            ref_ids = user_ids
        else:
            ref_ids = emp_ids
            
        if not ref_ids:
            continue
            
        ids_str = ", ".join(map(str, ref_ids))
        check_q = f"SELECT count(*), {col_name} FROM {table_name} WHERE {col_name} IN ({ids_str}) GROUP BY {col_name}"
        try:
            res = db.execute(text(check_q)).all()
            if res:
                print(f"Table '{table_name}' column '{col_name}' references '{ref_table}':")
                for count, ref_id in res:
                    name = db.execute(text(f"SELECT name FROM {ref_table} WHERE id = {ref_id}")).first()[0]
                    print(f"  - Count={count} for ID={ref_id} ({name})")
        except Exception as e:
            print(f"Failed to query {table_name}: {e}")

except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
