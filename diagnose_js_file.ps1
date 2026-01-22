$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking what's being served for main.bab53dbb.js..."
Write-Host "`n1. Testing the JS file directly:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventory/static/js/main.bab53dbb.js' | head -c 100"

Write-Host "`n`n2. Checking if file exists on server:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -lh /var/www/html/inventory/static/js/main.bab53dbb.js"

Write-Host "`n3. Checking Nginx location block for /inventory/:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 5 'location /inventory/' /etc/nginx/sites-enabled/pomma"

Write-Host "`n4. Testing what index.html references:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep 'main.*\.js' /var/www/html/inventory/index.html"
