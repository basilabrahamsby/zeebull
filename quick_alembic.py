import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('34.162.60.52', username='daionmathew12', password='350@bullet@?:')
stdin, stdout, stderr = client.exec_command('sudo -S git -C /var/www/zeebull fetch https://github.com/daionmathew12/zeebull.git main && sudo -S git -C /var/www/zeebull reset --hard FETCH_HEAD && cd /var/www/zeebull/ResortApp && echo "350@bullet@?:" | sudo -S /var/www/zeebull/ResortApp/venv/bin/alembic upgrade head && sudo -S systemctl restart zeebull')
print(stdout.read().decode())
print(stderr.read().decode())
client.close()
