$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Testing API endpoint via public URL..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I https://teqmates.com/inventoryapi/api/public/rooms | head -n 5"

Write-Host "`nTesting resort-info endpoint..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I https://teqmates.com/inventoryapi/api/resort-info/ | head -n 5"
