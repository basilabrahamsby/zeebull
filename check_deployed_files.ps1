$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking deployed Userend files..."
Write-Host "`n1. Listing files in /var/www/html/inventory/:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -lh /var/www/html/inventory/"

Write-Host "`n2. Checking if CSS file exists:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -lh /var/www/html/inventory/static/css/"

Write-Host "`n3. Checking what index.html loads:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "cat /var/www/html/inventory/index.html"

Write-Host "`n4. Testing if we can access the page locally on server:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'http://localhost/inventory/' | grep -o '<title>[^<]*</title>'"
