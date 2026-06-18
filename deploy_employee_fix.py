
import paramiko
import sys

host = "34.162.60.52"
username = "daionmathew12"
password = "350@bullet@?:"

print(f"Connecting to {host} as {username}...")
client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    client.connect(hostname=host, username=username, password=password, timeout=30)
    print("Connection successful!")
    
    # 1. First, push the latest code (which includes the fix_employees_final.py script)
    commands = [
        "sudo -S git -C /var/www/zeebull fetch https://github.com/daionmathew12/zeebull.git main",
        "sudo -S git -C /var/www/zeebull reset --hard FETCH_HEAD",
        "sudo -S systemctl restart zeebull"
    ]
    
    for cmd in commands:
        print(f"Executing: {cmd}")
        stdin, stdout, stderr = client.exec_command(cmd)
        if "sudo -S" in cmd:
            stdin.write(password + "\n")
            stdin.flush()
        
        stdout.read() # wait for completion
        
    # 2. Now run the check script on the server
    print("Running user data check script on server...")
    check_cmd = "cd /var/www/zeebull/ResortApp && /var/www/zeebull/ResortApp/venv/bin/python check_users.py"
    stdin, stdout, stderr = client.exec_command(check_cmd)

    out = stdout.read().decode()
    err = stderr.read().decode()

    if out:
        print("--- Check Output ---")
        print(out)
    if err:
        print("--- Check Status/Error ---")
        print(err)

            
except Exception as e:
    print(f"Error: {e}")
finally:
    client.close()
