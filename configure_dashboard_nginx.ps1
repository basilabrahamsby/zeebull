$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Uploading Nginx config script..."
scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\add_dashboard_nginx.py" "${remote}:~/add_dashboard_nginx.py"

Write-Host "2. Running config script..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo python3 ~/add_dashboard_nginx.py"

Write-Host "3. Testing Nginx config..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo nginx -t"

Write-Host "4. Reloading Nginx..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl reload nginx"

Write-Host "5. Verifying Dashboard is accessible..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventoryadmin/' | head -n 5"

Write-Host "`n✅ Dashboard deployed successfully!"
Write-Host "Access at: https://teqmates.com/inventoryadmin/"
