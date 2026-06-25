import paramiko
import sys

sys.stdout.reconfigure(encoding='utf-8')

def run_alembic():
    host = "34.162.60.52"
    user = "daionmathew12"
    pwd = "350@bullet@?:"
    
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname=host, username=user, password=pwd)
        cmd = """
        cd /var/www/zeebull/ResortApp
        echo '350@bullet@?:' | sudo -S ./venv/bin/alembic upgrade head
        """
        stdin, stdout, stderr = client.exec_command(cmd)
        
        out = stdout.read().decode('utf-8', errors='ignore')
        err = stderr.read().decode('utf-8', errors='ignore')
        print("STDOUT:", out)
        print("STDERR:", err)
    finally:
        client.close()

if __name__ == "__main__":
    run_alembic()
