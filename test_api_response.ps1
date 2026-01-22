$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Testing what the API endpoint returns..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventoryapi/api/public/rooms'"

Write-Host "`n`nTesting backend directly on localhost..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'http://127.0.0.1:8011/api/public/rooms' | head -c 200"
