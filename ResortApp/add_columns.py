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
        
        # Read the .env file to get the db connection
        cmd_env = 'cat /var/www/zeebull/ResortApp/.env | grep DATABASE_URL'
        stdin, stdout, stderr = client.exec_command(cmd_env)
        env_out = stdout.read().decode('utf-8').strip()
        print("ENV OUT:", env_out)
        
        # Parse db name
        if env_out:
            db_name = env_out.split('/')[-1]
            print("DB NAME:", db_name)
        else:
            db_name = "orchid_resort" # fallback
        
        sql = """
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS opening_account_balance FLOAT DEFAULT 0.0;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS closing_account_balance FLOAT DEFAULT 0.0;
        ALTER TABLE day_audits ADD COLUMN IF NOT EXISTS system_expected_account FLOAT DEFAULT 0.0;
        """
        
        # In psql, we can just use the full url if we want, or sudo -u postgres psql -d <dbname>
        # Let's try with the dbname parsed
        cmd = f"""
        echo "{pwd}" | sudo -S -u postgres psql -d {db_name} -c "{sql}"
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
