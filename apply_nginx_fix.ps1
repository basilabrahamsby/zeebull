$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Uploading fix script..."
scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\fix_nginx_config.py" "${remote}:~/fix_nginx_config.py"

Write-Host "2. Backing up current config..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo cp /etc/nginx/sites-enabled/pomma /etc/nginx/sites-enabled/pomma.backup"

Write-Host "3. Running fix script..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo python3 ~/fix_nginx_config.py"

Write-Host "4. Testing Nginx config..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo nginx -t"

Write-Host "5. Reloading Nginx..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl reload nginx"

Write-Host "6. Verifying fix..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 2 'location /inventoryapi/' /etc/nginx/sites-enabled/pomma"

Write-Host "`nNginx configuration fixed successfully!"
