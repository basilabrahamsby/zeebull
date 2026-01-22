$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Creating Dashboard directory on server..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo mkdir -p /var/www/html/inventoryadmin"

Write-Host "2. Uploading Dashboard build files..."
scp -r -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\dasboard\build" "${remote}:~/dashboard_build"

Write-Host "3. Moving files to web directory..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo rm -rf /var/www/html/inventoryadmin/* && sudo cp -r ~/dashboard_build/* /var/www/html/inventoryadmin/ && sudo chmod -R 755 /var/www/html/inventoryadmin/"

Write-Host "4. Configuring Nginx for Dashboard..."
$nginxConfig = @'
    location /inventoryadmin/ {
        alias /var/www/html/inventoryadmin/;
        try_files $uri $uri/ /inventoryadmin/index.html;
        add_header Cache-Control "no-cache, must-revalidate";
    }
'@

# Upload config snippet
$nginxConfig | Out-File -FilePath "c:\releasing\New Orchid\dashboard_nginx.conf" -Encoding ASCII

Write-Host "Dashboard deployed! Access at: https://teqmates.com/inventoryadmin/"
Write-Host "`nNote: You'll need to manually add the Nginx location block to /etc/nginx/sites-enabled/pomma"
