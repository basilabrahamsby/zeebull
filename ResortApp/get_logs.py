import paramiko
import sys

sys.stdout.reconfigure(encoding='utf-8')

def get_logs():
    host = "34.162.60.52"
    user = "daionmathew12"
    pwd = "350@bullet@?:"
    
    print(f"Connecting to {host}...")
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname=host, username=user, password=pwd)
        cmd = "echo '350@bullet@?:' | sudo -S journalctl -u zeebull.service -n 100 --no-pager"
        stdin, stdout, stderr = client.exec_command(cmd)
        
        out = stdout.read().decode('utf-8', errors='ignore')
        print(out)
    finally:
        client.close()

if __name__ == "__main__":
    get_logs()
