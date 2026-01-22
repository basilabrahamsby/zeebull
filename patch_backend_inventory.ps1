$ErrorActionPreference = "Stop"
$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$localFile = "c:\releasing\New Orchid\ResortApp\app\api\inventory.py"

Write-Host "Uploading inventory.py..."
scp -o StrictHostKeyChecking=no -i $pem $localFile "${remote}:~/inventory.py"

Write-Host "Patching and Restarting..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo cp ~/inventory.py /var/www/inventory/ResortApp/app/api/inventory.py && sudo systemctl restart inventory-resort.service"

Write-Host "Done! Inventory Backend Patched."
