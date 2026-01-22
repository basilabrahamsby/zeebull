$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Reading Nginx Config..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "cat /etc/nginx/sites-enabled/pomma"

Write-Host "`nTesting Public URL via Localhost (Loopback)..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -v -H 'Host: teqmates.com' http://127.0.0.1/inventoryapi/api/public/rooms"
