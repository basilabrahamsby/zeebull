import requests
import json
import os

# Get token for admin@orchid.com if possible, or just query DB
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
    # Get a list of users to see the structure of the data expected by the frontend
    res = conn.execute(text("SELECT u.id, u.email, u.name, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id;"))
    users = []
    for row in res:
        users.append({
            "id": row[0],
            "email": row[1],
            "name": row[2],
            "role": {"name": row[3]} # Mimic the structure the frontend expects
        })
    print(json.dumps(users[:30], indent=2))
