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
    emp_count = conn.execute(text("SELECT count(*) FROM employees;")).scalar()
    print(f"Total Employees: {emp_count}")
    
    res = conn.execute(text("SELECT id, name, user_id FROM employees LIMIT 20;"))
    print("\nEmployees:")
    for row in res:
        print(row)
