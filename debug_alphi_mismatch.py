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
    print("USERS WITH 'alphi' IN EMAIL OR NAME:")
    res = conn.execute(text("SELECT u.id, u.email, u.name, r.name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email ILIKE '%alphi%' OR u.name ILIKE '%alphi%';"))
    for row in res:
        print(f"  UserID: {row[0]} | Email: {row[1]} | Name: {row[2]} | Role: {row[3]}")
    
    print("\nEMPLOYEE RECORDS WITH 'alphi' IN NAME:")
    res = conn.execute(text("SELECT id, name, user_id, role FROM employees WHERE name ILIKE '%alphi%';"))
    for row in res:
        print(f"  EmpID: {row[0]} | Name: {row[1]} | UserID: {row[2]} | Role: {row[3]}")
