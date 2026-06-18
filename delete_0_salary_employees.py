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
engine = create_engine(DATABASE_URL)

def cleanup():
    with engine.connect() as conn:
        print("Finding employees with salary = 0 or NULL excluding admin@orchid.com...")
        
        sql_select = text('''
            SELECT e.id, e.name, e.salary, u.email 
            FROM employees e 
            LEFT JOIN users u ON e.user_id = u.id 
            WHERE (e.salary <= 0 OR e.salary IS NULL)
            AND (u.email != 'admin@orchid.com' OR u.email IS NULL)
        ''')
        to_delete = conn.execute(sql_select).fetchall()
        
        if not to_delete:
            print("No employees matching criteria found.")
            return
            
        for emp in to_delete:
            print(f"To delete -> ID: {emp[0]}, Name: {emp[1]}, Salary: {emp[2]}, Email: {emp[3]}")
            
        sql_delete = text('''
            DELETE FROM employees 
            WHERE (salary <= 0 OR salary IS NULL)
            AND id NOT IN (
                SELECT e.id FROM employees e 
                JOIN users u ON e.user_id = u.id 
                WHERE u.email = 'admin@orchid.com'
            )
        ''')
        res = conn.execute(sql_delete)
        conn.commit()
        print(f"✓ Deleted {res.rowcount} records from employees.")

if __name__ == '__main__':
    cleanup()
"""

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
