import paramiko
import sys

host = "34.162.60.52"
username = "daionmathew12"
password = "350@bullet@?:"

print(f"Connecting to {host} as {username}...")
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    client.connect(hostname=host, username=username, password=password, timeout=10)
    print("Connection successful!")
    
    script_content = """import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('/var/www/zeebull/ResortApp/.env')
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    print("DATABASE_URL not found!")
    exit(1)

engine = create_engine(DATABASE_URL)

def cleanup():
    with engine.connect() as conn:
        print("Finding triggers on 'users' table...")
        sql = text("SELECT trigger_name FROM information_schema.triggers WHERE event_object_table = 'users'")
        triggers = conn.execute(sql).mappings().all()
        for t in triggers:
            name = t['trigger_name']
            print(f"Dropping trigger: {name}")
            conn.execute(text(f"DROP TRIGGER IF EXISTS {name} ON users;"))
            conn.commit()
            print(f"✓ Dropped {name}")

        print("Finding triggers on 'employees' table...")
        sql = text("SELECT trigger_name FROM information_schema.triggers WHERE event_object_table = 'employees'")
        triggers = conn.execute(sql).mappings().all()
        for t in triggers:
            name = t['trigger_name']
            print(f"Dropping trigger: {name}")
            conn.execute(text(f"DROP TRIGGER IF EXISTS {name} ON employees;"))
            conn.commit()
            print(f"✓ Dropped {name}")
            
        print("Cleaning up guest records in 'employees' table...")
        sql = text("DELETE FROM employees WHERE user_id IN (SELECT id FROM users WHERE email LIKE 'guest_%' OR email LIKE '%@temp.com')")
        conn.execute(sql)
        conn.commit()
        print(f"✓ Deleted guest records from employees.")

if __name__ == '__main__':
    cleanup()
"""

    print("Executing cleanup script on server...")
    stdin, stdout, stderr = client.exec_command("cd /var/www/zeebull/ResortApp && /var/www/zeebull/ResortApp/venv/bin/python")
    stdin.write(script_content)
    stdin.close()
    
    out = stdout.read().decode()
    err = stderr.read().decode()
    
    if out:
        print("--- Output ---")
        print(out)
    if err:
        print("--- Error ---")
        print(err)
        
except Exception as e:
    print(f"Error: {e}")
finally:
    client.close()
