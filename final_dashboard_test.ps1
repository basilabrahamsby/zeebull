$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Testing Dashboard at /inventory/admin/..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventory/admin/' | head -n 10"

Write-Host "`n`nVerifying Nginx configuration..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 4 'location /inventory/admin/' /etc/nginx/sites-enabled/pomma"

Write-Host "`n`nTesting a deep route (should not 500 on refresh)..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventory/admin/dashboard' | head -n 5"
