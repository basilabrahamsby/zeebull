
$server_ip = "136.113.93.47"
$user = "basilabrahamaby"
$key = "$env:USERPROFILE\.ssh\gcp_key"

# Copy room.py
scp -o StrictHostKeyChecking=no -i $key "c:\releasing\New Orchid\ResortApp\app\api\room.py" $user@$server_ip`:~/orchid-repo/ResortApp/app/api/room.py
if ($LASTEXITCODE -ne 0) { Write-Host "SCP Failed"; exit 1 }

# Copy to deployment dir
ssh -o StrictHostKeyChecking=no -i $key $user@$server_ip "sudo cp ~/orchid-repo/ResortApp/app/api/room.py /var/www/inventory/ResortApp/app/api/room.py"
if ($LASTEXITCODE -ne 0) { Write-Host "Copy Failed"; exit 1 }

# Restart service
ssh -o StrictHostKeyChecking=no -i $key $user@$server_ip "sudo systemctl restart inventory-resort.service"
if ($LASTEXITCODE -ne 0) { Write-Host "Restart Failed"; exit 1 }

Write-Host "Deployed room.py successfully."
