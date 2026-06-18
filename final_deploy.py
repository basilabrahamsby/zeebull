
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
    
    commands = [
        "sudo -S git -C /var/www/zeebull fetch https://github.com/daionmathew12/zeebull.git main",
        "sudo -S git -C /var/www/zeebull reset --hard FETCH_HEAD",
        "sudo -S systemctl restart zeebull",
        "cd /var/www/zeebull/dasboard && sudo -S npm run build",
        "sudo -S systemctl reload nginx"
    ]
    
    for cmd in commands:
        print(f"Executing: {cmd}")
        stdin, stdout, stderr = client.exec_command(cmd)
        
        if "sudo -S" in cmd:
            stdin.write(password + "\n")
            stdin.flush()
        
        out = stdout.read().decode()
        err = stderr.read().decode()
        
        if out:
            print("--- Output ---")
            print(out)
        if err:
             # git fetch outputs to stderr even on success
            if "fetch" in cmd or "reset" in cmd or "build" in cmd:
                 print("--- Status/Output ---")
                 print(err)
            else:
                print("--- Error ---")
                print(err)
            
except Exception as e:
    print(f"Error: {e}")
finally:
    client.close()
