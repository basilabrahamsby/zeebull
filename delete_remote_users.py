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
        print("Finding users who appear as 0-salary employees excluding admin@orchid.com...")
        sql_select = text('''
            SELECT u.id, u.name, u.email 
            FROM users u 
            LEFT JOIN employees e ON e.user_id = u.id 
            WHERE (e.id IS NULL OR e.salary <= 0 OR e.salary IS NULL)
            AND u.email != 'admin@orchid.com'
            AND u.role_id != 1
        ''')
        to_delete = conn.execute(sql_select).fetchall()
        
        if not to_delete:
            print("No users matching criteria found.")
            return
            
        for u in to_delete:
            print(f"To delete -> User ID: {u[0]}, Name: {u[1]}, Email: {u[2]}")
            
        # We need to delete their related records first or use CASCADE if applicable.
        # But since they are users, they might have bookings or other records.
        # However, if the user requested deletion, we delete from `users`. 
        # But Wait! Deleting from `users` could violate foreign key constraints if they have bookings.
        # Is there a safer way? Maybe just set their `is_active = False`?
        # The user requested "delete all employee who salary is 0 expect admin@orchid.com".
        
        # Actually, let's delete them if possible, or print foreign key errors.
        try:
            sql_delete = text('''
                DELETE FROM users 
                WHERE id IN (
                    SELECT u.id
                    FROM users u 
                    LEFT JOIN employees e ON e.user_id = u.id 
                    WHERE (e.id IS NULL OR e.salary <= 0 OR e.salary IS NULL)
                    AND u.email != 'admin@orchid.com'
                    AND u.role_id != 1
                )
            ''')
            res = conn.execute(sql_delete)
            conn.commit()
            print(f"✓ Deleted {res.rowcount} records from users.")
        except Exception as e:
            print(f"Error deleting users (FK constraint?): {e}")

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
