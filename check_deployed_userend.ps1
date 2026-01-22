$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking Userend deployment on server..."
Write-Host "`n1. Files in /var/www/html/inventory/:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -lh /var/www/html/inventory/ | head -n 15"

Write-Host "`n2. Checking env.js content in deployed build:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "find /var/www/html/inventory/static/js -name 'main.*.js' -exec grep -l 'isInventoryDeployment' {} \; | head -n 1"

Write-Host "`n3. Checking index.html modification time:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "stat /var/www/html/inventory/index.html | grep Modify"

Write-Host "`n4. Checking when we last deployed Userend:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -lt /var/www/html/inventory/static/js/ | head -n 5"

Write-Host "`n5. Testing if the deployed files are being served:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'https://teqmates.com/inventory/index.html' | grep -o 'main\.[a-z0-9]*\.js'"
