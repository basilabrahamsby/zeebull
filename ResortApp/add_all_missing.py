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
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS opening_notes TEXT;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS closing_notes TEXT;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS override_reason TEXT;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS total_purchases FLOAT DEFAULT 0.0;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS new_checkins INTEGER DEFAULT 0;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS new_checkouts INTEGER DEFAULT 0;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS audit_log JSON;
        """
        
        cmd = f"""
        echo "{pwd}" | sudo -S -u postgres psql -d zeebuldb -c "{sql}"
        """
        
        stdin, stdout, stderr = client.exec_command(cmd)
        
        out = stdout.read().decode('utf-8', errors='ignore')
        err = stderr.read().decode('utf-8', errors='ignore')
        print("STDOUT:", out)
        print("STDERR:", err)
        
        # Then restart the service to apply
        restart_cmd = f'echo "{pwd}" | sudo -S systemctl restart zeebull.service'
        client.exec_command(restart_cmd)
        print("Service restarted.")
    finally:
        client.close()

if __name__ == "__main__":
    run_psql()
