$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Fixing Nginx /inventory/ location block..."
scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\fix_inventory_nginx.py" "${remote}:~/fix_inventory_nginx.py"
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo python3 ~/fix_inventory_nginx.py"

Write-Host "`nTesting Nginx config..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo nginx -t"

Write-Host "`nReloading Nginx..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl reload nginx"

Write-Host "`nVerifying JS file is now served correctly..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventory/static/js/main.bab53dbb.js' | head -c 50"

Write-Host "`n`n✅ Nginx configuration fixed!"
Write-Host "Please refresh the Userend page now."
