$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking proxy context..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -C 2 'inventoryapi' /etc/nginx/sites-enabled/pomma"
