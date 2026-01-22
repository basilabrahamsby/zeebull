$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking recent backend errors..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo journalctl -u inventory-resort.service --since '2 minutes ago' --no-pager | grep -i error"

Write-Host "`n`nTesting Userend public endpoints..."
Write-Host "1. Testing /api/public/rooms..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -w '\nStatus: %{http_code}\n' 'https://teqmates.com/inventoryapi/api/public/rooms' -o /dev/null"

Write-Host "`n2. Testing /api/resort-info/..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -w '\nStatus: %{http_code}\n' 'https://teqmates.com/inventoryapi/api/resort-info/' -o /dev/null"

Write-Host "`n3. Testing /api/gallery/..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -w '\nStatus: %{http_code}\n' 'https://teqmates.com/inventoryapi/api/gallery/' -o /dev/null"

Write-Host "`n4. Checking if Userend files are accessible..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventory/' | head -n 5"
