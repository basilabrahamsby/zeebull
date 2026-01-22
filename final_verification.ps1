$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "=== FINAL VERIFICATION ==="
Write-Host "`n1. Testing Userend API endpoints..."
Write-Host "   /api/public/rooms:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -w 'Status: %{http_code}\n' 'https://teqmates.com/inventoryapi/api/public/rooms' -o /dev/null"

Write-Host "`n   /api/resort-info/:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s -w 'Status: %{http_code}\n' 'https://teqmates.com/inventoryapi/api/resort-info/' -o /dev/null"

Write-Host "`n2. Checking Userend index.html..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventory/' | grep -o 'main\.[a-z0-9]*\.js' | head -n 1"

Write-Host "`n3. Verifying Nginx proxy configuration..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -A 2 'location /inventoryapi/' /etc/nginx/sites-enabled/pomma | grep proxy_pass"

Write-Host "`n4. Testing actual API response (should be JSON)..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventoryapi/api/public/rooms' | head -c 100"

Write-Host "`n`n=== ALL TESTS COMPLETE ==="
