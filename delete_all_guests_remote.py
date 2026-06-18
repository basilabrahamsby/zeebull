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
        print("Finding guest roles...")
        role_res = conn.execute(text("SELECT id FROM roles WHERE name = 'guest' OR name = 'Guest'")).fetchall()
        if not role_res:
            print("Guest role not found!")
            return
            
        guest_role_ids = [str(r[0]) for r in role_res]
        guest_roles_str = ",".join(guest_role_ids)
        print(f"Guest role IDs: {guest_roles_str}")
        
        print("Finding guests in employees table...")
        sql_find = text(f"SELECT e.id, e.name FROM employees e JOIN users u ON e.user_id = u.id WHERE u.role_id IN ({guest_roles_str})")
        guests = conn.execute(sql_find).fetchall()
        for g in guests:
            print(f"Found guest as employee: ID={g[0]}, Name={g[1]}")
            
        print("Cleaning up ALL guest records from 'employees' table...")
        sql_delete = text(f"DELETE FROM employees WHERE user_id IN (SELECT id FROM users WHERE role_id IN ({guest_roles_str}))")
        res = conn.execute(sql_delete)
        conn.commit()
        print(f"✓ Deleted {res.rowcount} guest records from employees.")

if __name__ == '__main__':
    cleanup()
"""

    print("Executing complete guest cleanup script on server...")
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
