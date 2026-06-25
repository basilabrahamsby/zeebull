import paramiko

host = '35.224.72.199'
username = 'daionmathew12'
password = '350@bullet@?:'

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(hostname=host, username=username, password=password, timeout=10)

print('Checking directories on 35.224.72.199...')
stdin, stdout, stderr = client.exec_command('ls -la /var/www/teqmates')
print('/var/www/teqmates:', stdout.read().decode())

stdin, stdout, stderr = client.exec_command('ls -la /var/www/zeebull')
print('/var/www/zeebull:', stdout.read().decode())

client.close()
print('Frontend build output:', stdout.read().decode())
print('Frontend build err:', stderr.read().decode())

print('Restarting zeebull backend service...')
stdin, stdout, stderr = client.exec_command('echo "350@bullet@?:" | sudo -S systemctl restart zeebull.service')
print('Restart output:', stdout.read().decode())
print('Restart err:', stderr.read().decode())

client.close()
