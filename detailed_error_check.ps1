$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Getting detailed Nginx error logs..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo tail -n 100 /var/log/nginx/error.log | tail -n 20"

Write-Host "`n`nTesting the exact URL the user is accessing..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -v 'https://teqmates.com/inventoryapi/admin/account' 2>&1 | head -n 50"

Write-Host "`n`nChecking if backend is responding on port 8011..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -v 'http://127.0.0.1:8011/admin/account' 2>&1 | head -n 30"
