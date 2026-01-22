$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Restarting backend service..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl restart inventory-resort.service"

Write-Host "Waiting for service to start..."
Start-Sleep -Seconds 3

Write-Host "`nChecking service status..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl status inventory-resort.service | head -n 15"

Write-Host "`nTesting API endpoints..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -w '\nHTTP Status: %{http_code}\n' https://teqmates.com/inventoryapi/api/resort-info/ | head -c 100"

Write-Host "`n`nTesting public rooms endpoint..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -w '\nHTTP Status: %{http_code}\n' https://teqmates.com/inventoryapi/api/public/rooms | head -c 100"
