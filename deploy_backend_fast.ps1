$ErrorActionPreference = "Stop"
$baseDir = "C:\releasing\New Orchid"
$backendDir = "$baseDir\ResortApp"
$backendZip = "$baseDir\backend_deploy_fast.zip"
$serverIP = "136.113.93.47"
$username = "basilabrahamaby"
$sshKey = "$env:USERPROFILE\.ssh\gcp_key"

Write-Host "Packaging Backend..."
if (Test-Path $backendZip) { Remove-Item $backendZip -Force }
Get-ChildItem -Path $backendDir -Exclude "venv", "__pycache__", ".git", ".env", ".idea", ".vscode" | Compress-Archive -DestinationPath $backendZip -CompressionLevel Optimal

Write-Host "Uploading Backend..."
scp -i $sshKey $backendZip "${username}@${serverIP}:~/backend_deploy_fast.zip"

Write-Host "Deploying..."
$deployScript = @"
echo '[Backend] Extracting...'
rm -rf /home/basilabrahamaby/ResortApp_Fast
mkdir -p /home/basilabrahamaby/ResortApp_Fast
# Try unzip, if fails use python
if command -v unzip >/dev/null; then
    unzip -o /home/basilabrahamaby/backend_deploy_fast.zip -d /home/basilabrahamaby/ResortApp_Fast
else
    python3 -m zipfile -e /home/basilabrahamaby/backend_deploy_fast.zip /home/basilabrahamaby/ResortApp_Fast
fi

echo 'Listing extracted files (head):'
ls -la /home/basilabrahamaby/ResortApp_Fast | head -n 5

echo '[Backend] Copying files...'
sudo cp -r /home/basilabrahamaby/ResortApp_Fast/* /var/www/inventory/ResortApp/

echo '[Service] Restarting backend...'
sudo systemctl restart inventory-resort.service
"@
ssh -i $sshKey -o StrictHostKeyChecking=no "${username}@${serverIP}" $deployScript
Write-Host "Backend Deployed Successfully!"
