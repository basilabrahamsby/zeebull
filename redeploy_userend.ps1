$ErrorActionPreference = "Stop"

$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "1. Syncing env.js..."
Copy-Item "c:\releasing\New Orchid\dasboard\src\utils\env.js" "c:\releasing\New Orchid\userend\src\utils\env.js" -Force

Write-Host "2. Building Userend..."
Set-Location "c:\releasing\New Orchid\userend"
$env:CI = "false"
npm run build
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

Write-Host "3. Uploading to ~/userend_build..."
# Make sure we are uploading the 'build' FOLDER as 'userend_build'
# scp -r build user@host:~/userend_build
ssh -o StrictHostKeyChecking=no -i $pem $remote "rm -rf ~/userend_build"
scp -r -o StrictHostKeyChecking=no -i $pem "build" "${remote}:~/userend_build"
if ($LASTEXITCODE -ne 0) { throw "SCP upload failed" }

Write-Host "4. Deploying to /var/www/html/orchid/..."
# Sudo move files to destination
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo rm -rf /var/www/html/orchid/* && sudo cp -r ~/userend_build/* /var/www/html/orchid/ && sudo chmod -R 755 /var/www/html/orchid/"
if ($LASTEXITCODE -ne 0) { throw "Deployment failed" }

Write-Host "Success!"
