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
    count = conn.execute(text("SELECT count(*) FROM users;")).scalar()
    print(f"Total Users: {count}")
    
    count_non_guest = conn.execute(text("SELECT count(*) FROM users u JOIN roles r ON u.role_id = r.id WHERE r.name != 'guest';")).scalar()
    print(f"Total Non-Guest Users: {count_non_guest}")

    # Check order
    res = conn.execute(text("SELECT u.id, u.email, r.name FROM users u JOIN roles r ON u.role_id = r.id ORDER BY u.id LIMIT 20;"))
    print("\nFirst 20 Users:")
    for row in res:
        print(row)
