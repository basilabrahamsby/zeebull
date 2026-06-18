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
        print("Deleting Alen and Mirzz from employees...")
        sql = text("DELETE FROM employees WHERE name IN ('Alen', 'Mirzz')")
        res = conn.execute(sql)
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
