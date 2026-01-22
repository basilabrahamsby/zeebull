$ErrorActionPreference = "Stop"
$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

# 1. API File
$apiFile = "c:\releasing\New Orchid\ResortApp\app\api\booking.py"
Write-Host "Uploading booking.py (API)..."
scp -o StrictHostKeyChecking=no -i $pem $apiFile "${remote}:~/booking_api.py"

# 2. Schema File
$schemaFile = "c:\releasing\New Orchid\ResortApp\app\schemas\booking.py"
Write-Host "Uploading booking.py (Schema)..."
scp -o StrictHostKeyChecking=no -i $pem $schemaFile "${remote}:~/booking_schema.py"

Write-Host "Patching and Restarting..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo cp ~/booking_api.py /var/www/inventory/ResortApp/app/api/booking.py && sudo cp ~/booking_schema.py /var/www/inventory/ResortApp/app/schemas/booking.py && sudo systemctl restart inventory-resort.service"

Write-Host "Done! Full Booking Logic Patched."
