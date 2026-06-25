import paramiko
import sys
import datetime

sys.stdout.reconfigure(encoding='utf-8')

def backup_db():
    host = "34.162.60.52"
    user = "daionmathew12"
    pwd = "350@bullet@?:"
    
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    tmp_file = f"/tmp/zeebuldb_backup_{timestamp}.sql"
    final_file = f"/home/daionmathew12/zeebuldb_backup_{timestamp}.sql"
    
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(hostname=host, username=user, password=pwd)
        
        # Run pg_dump as postgres and redirect to /tmp where it's writable
        cmd = f"""
        echo "{pwd}" | sudo -S -u postgres bash -c "pg_dump zeebuldb > {tmp_file}"
        echo "{pwd}" | sudo -S cp {tmp_file} {final_file}
        echo "{pwd}" | sudo -S chown daionmathew12:daionmathew12 {final_file}
        ls -lh {final_file}
        """
        
        print("Executing pg_dump on server...")
        stdin, stdout, stderr = client.exec_command(cmd)
        
        out = stdout.read().decode('utf-8', errors='ignore')
        err = stderr.read().decode('utf-8', errors='ignore')
        
        print("STDOUT:", out)
        if err:
            print("STDERR:", err)
            
    finally:
        client.close()

if __name__ == "__main__":
    backup_db()
