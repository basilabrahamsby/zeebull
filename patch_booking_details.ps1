$ErrorActionPreference = "Stop"
$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$snippetFile = "c:\releasing\New Orchid\booking_extension_snippet.py"

Write-Host "Uploading snippet..."
scp -o StrictHostKeyChecking=no -i $pem $snippetFile "${remote}:~/booking_snippet.py"

Write-Host "Appending to booking.py and Restarting..."
# Check if already patched to avoid double appending
ssh -o StrictHostKeyChecking=no -i $pem $remote "if ! grep -q 'BookingDetailsOut' /var/www/inventory/ResortApp/app/api/booking.py; then cat ~/booking_snippet.py >> /var/www/inventory/ResortApp/app/api/booking.py; fi && sudo systemctl restart inventory-resort.service"

Write-Host "Done! Booking Details Endpoint Added."
