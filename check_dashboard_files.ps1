$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking Dashboard deployment..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -lh /var/www/html/inventoryadmin/ | head -n 20"

Write-Host "`n`nChecking Nginx config for /inventoryadmin/..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 5 'inventoryadmin' /etc/nginx/sites-enabled/pomma"

Write-Host "`n`nTesting Dashboard index page..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventoryadmin/' | head -n 10"
