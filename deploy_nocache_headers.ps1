$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Adding no-cache headers to force browser refresh..."
scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\add_nocache_headers.py" "${remote}:~/add_nocache_headers.py"
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo python3 ~/add_nocache_headers.py"

Write-Host "`nTesting Nginx config..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo nginx -t"

Write-Host "`nReloading Nginx..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl reload nginx"

Write-Host "`nVerifying headers..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventory/' | grep -i cache"

Write-Host "`n✅ No-cache headers added. Please try accessing the Userend now."
Write-Host "The browser will be forced to fetch fresh files."
