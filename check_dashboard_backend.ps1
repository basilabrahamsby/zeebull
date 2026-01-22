$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Testing the dashboard endpoint that's failing..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'http://127.0.0.1:8011/admin/dashboard' 2>&1"

Write-Host "`n`nChecking recent backend errors..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo journalctl -u inventory-resort.service --since '2 minutes ago' --no-pager | grep -E 'ERROR|Exception|Traceback' -A 3"

Write-Host "`n`nChecking if /admin routes exist in backend..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "curl -s 'http://127.0.0.1:8011/docs' | grep -o '/admin[^\"]*' | head -n 10"
