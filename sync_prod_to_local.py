import paramiko
import os
import subprocess
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import sys

# Production Configuration
PROD_HOST = "34.162.60.52"
PROD_USER = "daionmathew12"
PROD_PASS = "350@bullet@?:"
PROD_DB = "zeebuldb"
REMOTE_BACKUP_PATH = "/tmp/zeebull_prod.backup"

# Local Configuration
LOCAL_DB_NAME = "zeebull"
LOCAL_ADMIN_URL = "postgresql://postgres:qwerty123@localhost:5432/postgres"
LOCAL_BACKUP_PATH = "zeebull_prod.backup"

def run_remote_command(client, command):
    print(f"Executing remote command: {command}")
    stdin, stdout, stderr = client.exec_command(command)
    exit_status = stdout.channel.recv_exit_status()
    out = stdout.read().decode()
    err = stderr.read().decode()
    if exit_status != 0:
        print(f"Error: {err}")
        return False, out, err
    return True, out, err

def main():
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        # 1. Connect to Production
        print(f"--- Connecting to Production ({PROD_HOST}) ---")
        client.connect(hostname=PROD_HOST, username=PROD_USER, password=PROD_PASS, timeout=15)
        print("Connected successfully.")

        # 2. Remote Backup (pg_dump)
        # We use custom format (-F c) for pg_restore
        print(f"--- Creating Remote Backup of {PROD_DB} ---")
        # Note: Production DB password is 'qwerty123' based on deployment_config
        dump_cmd = f"PGPASSWORD='qwerty123' pg_dump -U postgres -h localhost -F c -b -v -f {REMOTE_BACKUP_PATH} {PROD_DB}"
        success, out, err = run_remote_command(client, dump_cmd)
        if not success:
            print("Failed to create remote backup.")
            return

        # 3. Download Backup
        print("--- Downloading Backup File ---")
        sftp = client.open_sftp()
        sftp.get(REMOTE_BACKUP_PATH, LOCAL_BACKUP_PATH)
        sftp.close()
        print(f"Downloaded to {LOCAL_BACKUP_PATH}")

        # 4. Local DB Preparation
        print(f"--- Preparing Local Database: {LOCAL_DB_NAME} ---")
        conn = psycopg2.connect(LOCAL_ADMIN_URL)
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()

        # Terminate connections
        print("Terminating existing connections...")
        cursor.execute(f"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '{LOCAL_DB_NAME}' AND pid <> pg_backend_pid();")
        
        # Drop and Recreate
        print(f"Recreating database {LOCAL_DB_NAME}...")
        cursor.execute(f"DROP DATABASE IF EXISTS {LOCAL_DB_NAME};")
        cursor.execute(f"CREATE DATABASE {LOCAL_DB_NAME};")
        
        cursor.close()
        conn.close()
        print("Local database recreated.")

        # 5. Local Restore (pg_restore)
        print("--- Restoring Local Database ---")
        # We use --no-owner --no-acl to avoid permission issues locally
        pg_restore_path = r"C:\Program Files\PostgreSQL\18\bin\pg_restore.exe"
        restore_cmd = [
            pg_restore_path,
            "-U", "postgres",
            "-h", "localhost",
            "-d", LOCAL_DB_NAME,
            "--clean",
            "--if-exists",
            "--no-owner",
            "--no-acl",
            "-v",
            LOCAL_BACKUP_PATH
        ]
        
        # Set PGPASSWORD for local restore
        env = os.environ.copy()
        env["PGPASSWORD"] = "qwerty123" # Admin pass from LOCAL_ADMIN_URL
        
        process = subprocess.Popen(restore_cmd, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = process.communicate()
        
        if process.returncode != 0:
            print("Restore failed:")
            print(stderr)
        else:
            print("Restore completed successfully.")

        # 6. Cleanup Remote
        print("--- Cleaning up Remote Temporary File ---")
        run_remote_command(client, f"rm {REMOTE_BACKUP_PATH}")

        print("\nSUCCESS: Production database synced to local!")

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        client.close()

if __name__ == "__main__":
    main()
