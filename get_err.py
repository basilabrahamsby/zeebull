import paramiko

client = paramiko.SSHClient()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect('34.162.60.52', username='daionmathew12', password='350@bullet@?:')
stdin, stdout, stderr = client.exec_command('echo "350@bullet@?:" | sudo -S journalctl -u zeebull.service -n 500 | grep -i error')
print(stdout.read().decode())
client.close()
