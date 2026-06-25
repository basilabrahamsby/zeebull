import paramiko
import time
import sys

sys.stdout.reconfigure(encoding='utf-8')

def run_ssh_command(hostname, username, password, command):
    print(f"Connecting to {hostname}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname=hostname, username=username, password=password)
        print(f"Executing: {command}")
        stdin, stdout, stderr = client.exec_command(command)
        
        out = stdout.read().decode('utf-8', errors='ignore')
        err = stderr.read().decode('utf-8', errors='ignore')
        exit_status = stdout.channel.recv_exit_status()
        
        print("--- STDOUT ---")
        print(out)
        print("--- STDERR ---")
        print(err)
        print(f"Exit status: {exit_status}")
    finally:
        client.close()

if __name__ == "__main__":
    host = "34.162.60.52"
    user = "daionmathew12"
    pwd = "350@bullet@?:"
    
    cmd = f"""
    cd /var/www/zeebull
    echo "--- Pulling latest code from origin main in /var/www/zeebull ---"
    echo "{pwd}" | sudo -S git pull origin main
    
    echo "--- Restarting zeebull.service ---"
    echo "{pwd}" | sudo -S systemctl restart zeebull.service
    
    echo "--- Checking zeebull.service status ---"
    systemctl status zeebull.service --no-pager
    """
    
    run_ssh_command(host, user, pwd, cmd)
    
