$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking proxy_pass directive..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep 'proxy_pass' /etc/nginx/sites-enabled/pomma"
