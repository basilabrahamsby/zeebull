$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking for /inventoryapi/ block..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 10 'location /inventoryapi/' /etc/nginx/sites-enabled/pomma"

Write-Host "`nChecking for /inventory/ block..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 10 'location /inventory/' /etc/nginx/sites-enabled/pomma"
