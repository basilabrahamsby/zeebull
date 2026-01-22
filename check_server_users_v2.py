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
    # 1. Check if user exists
    target_email = 'housekeeping@orchid.com'
    res = conn.execute(text(f"SELECT u.id, u.email, r.name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = '{target_email}';"))
    user = res.fetchone()
    if not user:
        print(f"User {target_email} NOT FOUND")
    else:
        print(f"User found: ID={user[0]}, Email={user[1]}, Role={user[2]}")
        # 2. Check if employee record exists
        res = conn.execute(text(f"SELECT id, name, role FROM employees WHERE user_id = {user[0]};"))
        emp = res.fetchone()
        if not emp:
            print(f"Employee record for User ID {user[0]} NOT FOUND")
        else:
            print(f"Employee found: ID={emp[0]}, Name={emp[1]}, Role={emp[2]}")

    # 3. List all employees
    print("\nAll Employees in system:")
    res = conn.execute(text("SELECT e.id, e.name, u.email, e.role FROM employees e JOIN users u ON e.user_id = u.id;"))
    for row in res:
        print(f"ID: {row[0]}, Name: {row[1]}, Email: {row[2]}, Role: {row[3]}")
