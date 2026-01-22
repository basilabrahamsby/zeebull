$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Verifying Nginx proxy configuration..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 5 'location /inventoryapi/' /etc/nginx/sites-enabled/pomma"

Write-Host "`n2. Testing API with full response..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s https://teqmates.com/inventoryapi/api/resort-info/ | head -c 200"

Write-Host "`n`n3. Checking if backend is running..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl status inventory-resort.service | head -n 10"

Write-Host "`n4. Testing direct backend access..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s http://127.0.0.1:8011/api/resort-info/ | head -c 200"
