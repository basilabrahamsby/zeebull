$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking current Nginx config for /inventoryadmin/..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 10 'location.*inventoryadmin' /etc/nginx/sites-enabled/pomma"

Write-Host "`n`nChecking if Dashboard files exist..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -la /var/www/html/inventoryadmin/ 2>&1 | head -n 10"

Write-Host "`n`nLooking for any admin-related location blocks..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -n 'location.*admin' /etc/nginx/sites-enabled/pomma"
