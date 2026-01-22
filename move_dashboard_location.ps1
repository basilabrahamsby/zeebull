$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Uploading location update script..."
scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\update_dashboard_location.py" "${remote}:~/update_dashboard_location.py"

Write-Host "2. Updating Nginx configuration..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo python3 ~/update_dashboard_location.py"

Write-Host "3. Testing Nginx config..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo nginx -t"

Write-Host "4. Reloading Nginx..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl reload nginx"

Write-Host "5. Verifying new Dashboard location..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventory/admin/' | head -n 5"

Write-Host "`n✅ Dashboard moved to: https://teqmates.com/inventory/admin/"
