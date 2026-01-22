$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Removing problematic version parameters..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "cd /var/www/html/inventory && sudo sed -i 's/?v=20260109//g' index.html"

Write-Host "`nVerifying index.html is clean..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep 'src=' /var/www/html/inventory/index.html | head -n 3"

Write-Host "`n✅ Version parameters removed."
Write-Host "The no-cache headers will handle cache busting."
Write-Host "`nPlease refresh the page (Ctrl+Shift+R)"
