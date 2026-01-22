#!/usr/bin/env python3
"""Upload auth.py to server"""

import paramiko
import os

# Read the local file
with open(r'c:\releasing\New Orchid\ResortApp\app\api\auth.py', 'r') as f:
    content = f.read()

# SSH connection
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
key = paramiko.RSAKey.from_private_key_file(os.path.expanduser('~/.ssh/gcp_key'))
ssh.connect('136.113.93.47', username='basilabrahamaby', pkey=key)

# Upload file
sftp = ssh.open_sftp()
with sftp.file('/tmp/auth.py', 'w') as f:
    f.write(content)
sftp.close()

# Move to correct location and restart service
stdin, stdout, stderr = ssh.exec_command('sudo cp /tmp/auth.py /var/www/inventory/ResortApp/app/api/auth.py && sudo systemctl restart inventory-resort')
print(stdout.read().decode())
print(stderr.read().decode())

ssh.close()
print("File uploaded and service restarted!")
