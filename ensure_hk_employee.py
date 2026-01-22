import os
from sqlalchemy import create_engine, text
from datetime import date

db_url = None
with open('/var/www/inventory/ResortApp/.env') as f:
    for line in f:
        if line.startswith('DATABASE_URL='):
            db_url = line.split('=', 1)[1].strip()
            if (db_url.startswith('"') and db_url.endswith('"')) or (db_url.startswith("'") and db_url.endswith("'")):
                db_url = db_url[1:-1]
            break

if db_url.startswith('postgresql://'):
    db_url = db_url.replace('postgresql://', 'postgresql+psycopg2://')

engine = create_engine(db_url)
with engine.connect() as conn:
    target_email = 'housekeeping@orchid.com'
    res = conn.execute(text(f"SELECT u.id, u.name FROM users u WHERE u.email = '{target_email}';"))
    user = res.fetchone()
    
    if not user:
        print(f"User {target_email} not found. Cannot create employee.")
    else:
        user_id = user[0]
        user_name = user[1] or "Housekeeping Staff"
        
        # Check if employee exists
        res = conn.execute(text(f"SELECT id FROM employees WHERE user_id = {user_id};"))
        emp = res.fetchone()
        
        if emp:
            print(f"Employee record already exists for {target_email} (ID: {emp[0]})")
        else:
            print(f"Creating employee record for {target_email}...")
            # We need to be careful with the columns. Let's check columns first.
            cols_res = conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name = 'employees';"))
            cols = [c[0] for c in cols_res]
            print(f"Employee columns: {cols}")
            
            # Simple insert
            conn.execute(text(f"INSERT INTO employees (name, role, salary, join_date, user_id) VALUES ('{user_name}', 'housekeeping', 15000, '{date.today()}', {user_id});"))
            conn.commit()
            print(f"Employee record created for {target_email}")

    # Also check Dayon/daion to see if they are also HK
    res = conn.execute(text("SELECT email, name FROM users WHERE name ILIKE '%daion%' OR email ILIKE '%daion%' OR name ILIKE '%dayon%';"))
    for row in res:
        print(f"Found related user: {row[0]} ({row[1]})")
