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
    res = conn.execute(text("SELECT u.name, r.name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.name ILIKE '%bas%' OR u.name ILIKE '%hari%';"))
    for row in res:
        print(f"Name: {row[0]} | Role: {row[1]}")
