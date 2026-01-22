$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Testing the NEW Dashboard location..."
Write-Host "URL: https://teqmates.com/inventoryadmin/`n"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -I 'https://teqmates.com/inventoryadmin/' | head -n 10"

Write-Host "`n`nTesting if Dashboard files are accessible..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryadmin/' | head -c 500"

Write-Host "`n`n`nChecking what's at the API endpoint you're accessing..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'http://127.0.0.1:8011/admin/dashboard' | head -c 300"

Write-Host "`n`n`nVerifying Nginx config was updated..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 3 'location /inventoryadmin/' /etc/nginx/sites-enabled/pomma"
