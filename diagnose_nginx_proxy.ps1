$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking current Nginx proxy configuration..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 3 'location /inventoryapi/' /etc/nginx/sites-enabled/pomma"

Write-Host "`n`nTesting API endpoint directly..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryapi/api/public/rooms' | head -c 100"

Write-Host "`n`nChecking backend status..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl status inventory-resort.service | head -n 5"
