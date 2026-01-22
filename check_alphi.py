import os
from sqlalchemy import create_engine, text

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
    print("ROLES:")
    res = conn.execute(text("SELECT id, name FROM roles;"))
    for row in res:
        print(f"  ID: {row[0]} | Name: {row[1]}")
    
    print("\nUSER ALPHI:")
    res = conn.execute(text("SELECT u.id, u.email, u.name, r.name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = 'alphi@orchid.com';"))
    for row in res:
        print(f"  ID: {row[0]} | Email: {row[1]} | Name: {row[2]} | Role: {row[3]}")
    
    print("\nEMPLOYEE ALPHI:")
    if row: # Use last ID from previous loop
        res = conn.execute(text(f"SELECT id, name, role, user_id FROM employees WHERE user_id = {row[0]};"))
        for erow in res:
            print(f"  ID: {erow[0]} | Name: {erow[1]} | Role: {erow[2]} | UserID: {erow[3]}")
        if res.rowcount == 0:
            print("  No employee record found for this user.")
