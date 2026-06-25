import paramiko
import sys

sys.stdout.reconfigure(encoding='utf-8')

def run_psql():
    host = "34.162.60.52"
    user = "daionmathew12"
    pwd = "350@bullet@?:"
    
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname=host, username=user, password=pwd)
        
        sql = """
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS opening_cash_balance FLOAT DEFAULT 0.0;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS closing_cash_balance FLOAT DEFAULT 0.0;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS system_expected_cash FLOAT DEFAULT 0.0;
        """
        
        cmd = f"""
        echo "{pwd}" | sudo -S -u postgres psql -d zeebuldb -c "{sql}"
        """
        
        stdin, stdout, stderr = client.exec_command(cmd)
        
        out = stdout.read().decode('utf-8', errors='ignore')
        err = stderr.read().decode('utf-8', errors='ignore')
        print("STDOUT:", out)
        print("STDERR:", err)
    finally:
        client.close()

if __name__ == "__main__":
    run_psql()
