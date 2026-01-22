$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Testing Userend (the main site we fixed)..."
Write-Host "URL: https://teqmates.com/inventory/`n"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventory/' | head -c 500"

Write-Host "`n`n`nTesting if Userend can fetch API data..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryapi/api/public/rooms' | head -c 300"

Write-Host "`n`n`nTesting resort-info endpoint..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryapi/api/resort-info/' | head -c 300"
