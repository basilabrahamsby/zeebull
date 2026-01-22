
$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Creating Dashboard directory on server..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo mkdir -p /var/www/html/orchidadmin"

Write-Host "2. Uploading Dashboard build files..."
# Upload to home first to avoid permission issues
scp -r -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\dasboard\build" "${remote}:~/orchidadmin_build"

Write-Host "3. Moving files to web directory..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo rm -rf /var/www/html/orchidadmin/* && sudo cp -r ~/orchidadmin_build/* /var/www/html/orchidadmin/ && sudo chmod -R 755 /var/www/html/orchidadmin/ && rm -rf ~/orchidadmin_build"

Write-Host "Dashboard deployed to /var/www/html/orchidadmin/"
