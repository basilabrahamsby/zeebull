$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Building Dashboard..."
Set-Location "c:\releasing\New Orchid\dasboard"
$env:CI = "false"
npm run build
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

Write-Host "2. Uploading Dashboard build files..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "rm -rf ~/dashboard_build"
scp -r -o StrictHostKeyChecking=no -i $pem "build" "${remote}:~/dashboard_build"

Write-Host "3. Moving files to web directory /var/www/html/orchidadmin/..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo mkdir -p /var/www/html/orchidadmin && sudo rm -rf /var/www/html/orchidadmin/* && sudo cp -r ~/dashboard_build/* /var/www/html/orchidadmin/ && sudo chmod -R 755 /var/www/html/orchidadmin/"

Write-Host "4. Nginx is already updated via rename_paths_nginx.py script."
Write-Host "Dashboard deployed! Access at: https://teqmates.com/orchid/admin/"
