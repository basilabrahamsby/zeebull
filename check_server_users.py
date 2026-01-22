import os
from sqlalchemy import create_engine, text

# Try to load from .env
db_url = None
try:
    with open('/var/www/inventory/ResortApp/.env') as f:
        for line in f:
            if line.startswith('DATABASE_URL='):
                db_url = line.split('=', 1)[1].strip()
                if (db_url.startswith('"') and db_url.endswith('"')) or (db_url.startswith("'") and db_url.endswith("'")):
                    db_url = db_url[1:-1]
                break
except Exception as e:
    print(f"Error reading .env: {e}")
    exit(1)

if not db_url:
    print('DATABASE_URL not found in .env')
    exit(1)

if db_url.startswith('postgresql://'):
    db_url = db_url.replace('postgresql://', 'postgresql+psycopg2://')

try:
    engine = create_engine(db_url)
    with engine.connect() as conn:
        query = text('SELECT u.email, e.name as emp_name, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id LEFT JOIN employees e ON u.id = e.user_id;')
        res = conn.execute(query)
        print('Email | Employee Name | Role')
        print('---------------------------')
        for row in res:
            print(f'{row[0]} | {row[1]} | {row[2]}')
except Exception as e:
    print(f'Error: {e}')
