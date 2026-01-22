$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking if API endpoints have data..."
Write-Host "`n1. Checking /api/public/rooms:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryapi/api/public/rooms' | head -c 500"

Write-Host "`n`n2. Checking /api/resort-info/:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryapi/api/resort-info/'"

Write-Host "`n`n3. Checking if React root div exists in HTML:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventory/' | grep 'root'"

Write-Host "`n`n4. Checking page title:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventory/' | grep '<title>'"
