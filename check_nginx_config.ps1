$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking Nginx Configuration..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "cat /etc/nginx/sites-enabled/pomma"
