$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Testing admin/account endpoint..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryapi/admin/account' 2>&1"

Write-Host "`n`nChecking backend logs for errors..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo journalctl -u inventory-resort.service --since '5 minutes ago' --no-pager | tail -n 30"

Write-Host "`n`nTesting if /admin route exists..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventoryapi/admin' | head -n 10"

Write-Host "`n`nTesting root inventoryapi..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventoryapi/' | head -n 10"
