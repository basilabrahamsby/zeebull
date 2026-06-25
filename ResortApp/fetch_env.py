import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('34.162.60.52', username='daionmathew12', password='350@bullet@?:')

# Try reading from common paths
cmd = "echo '350@bullet@?:' | sudo -S bash -c 'cat /var/www/zeebull/ResortApp/.env || cat /var/www/teqmates/ResortApp/.env'"
stdin, stdout, stderr = client.exec_command(cmd)

with open('D:/Zeebull/ResortApp/remote_env.txt', 'w', encoding='utf-8') as f:
    f.write(stdout.read().decode('utf-8', errors='ignore'))
    f.write(stderr.read().decode('utf-8', errors='ignore'))
