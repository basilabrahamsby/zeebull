$ErrorActionPreference = "Stop"
$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$localFile = "c:\releasing\New Orchid\ResortApp\app\schemas\booking.py"

Write-Host "Uploading booking.py schema..."
scp -o StrictHostKeyChecking=no -i $pem $localFile "${remote}:~/booking_schema.py"

Write-Host "Patching and Restarting..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo cp ~/booking_schema.py /var/www/inventory/ResortApp/app/schemas/booking.py && sudo systemctl restart inventory-resort.service"

Write-Host "Done! Backend Booking Schema Patched."
