$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking Nginx Syntax..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo nginx -t"

Write-Host "`nChecking proxy_pass line (97)..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sed -n '97p' /etc/nginx/sites-enabled/pomma"
