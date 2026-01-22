import paramiko
import os

# SSH connection details
hostname = "136.113.93.47"
username = "basilabrahamaby"
key_path = os.path.expanduser("~/.ssh/gcp_key")

# File paths
local_file = r"c:\releasing\New Orchid\ResortApp\app\api\checkout.py"
remote_file = "/var/www/inventory/ResortApp/app/api/checkout.py"

print(f"Uploading {local_file} to {hostname}:{remote_file}")

# Create SSH client
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

try:
    # Connect using private key
    private_key = paramiko.RSAKey.from_private_key_file(key_path)
    ssh.connect(hostname, username=username, pkey=private_key)
    
    # Create SFTP client
    sftp = ssh.open_sftp()
    
    # Upload file
    sftp.put(local_file, remote_file)
    print(f"✓ File uploaded successfully!")
    
    # Verify file size
    remote_stat = sftp.stat(remote_file)
    local_size = os.path.getsize(local_file)
    print(f"Local file size: {local_size} bytes")
    print(f"Remote file size: {remote_stat.st_size} bytes")
    
    if local_size == remote_stat.st_size:
        print("✓ File sizes match!")
    else:
        print("⚠ Warning: File sizes don't match!")
    
    sftp.close()
    
    # Restart the backend service
    print("\nRestarting backend service...")
    stdin, stdout, stderr = ssh.exec_command("cd /var/www/inventory/ResortApp && sudo pkill -f 'uvicorn main:app' && nohup sudo /usr/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 8011 > /dev/null 2>&1 &")
    print("✓ Backend service restarted!")
    
except Exception as e:
    print(f"✗ Error: {e}")
finally:
    ssh.close()

print("\nDone!")
