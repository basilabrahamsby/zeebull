$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking Nginx configuration for /inventory/..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 10 'location /inventory/' /etc/nginx/sites-enabled/pomma"

Write-Host "`n`nChecking if files actually exist at the alias path..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -la /var/www/html/inventory/index.html"

Write-Host "`n`nTesting direct file access..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "cat /var/www/html/inventory/index.html | head -n 20"
