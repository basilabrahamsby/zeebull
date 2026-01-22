$ErrorActionPreference = "Stop"
$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$localFile = "c:\releasing\New Orchid\ResortApp\app\api\checkout.py"

Write-Host "Uploading checkout.py..."
scp -o StrictHostKeyChecking=no -i $pem $localFile "${remote}:~/checkout.py"

Write-Host "Patching and Restarting..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo cp ~/checkout.py /var/www/inventory/ResortApp/app/api/checkout.py && sudo systemctl restart inventory-resort.service"

Write-Host "Done! Checkout Backend Patched."
