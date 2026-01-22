$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$target_path = "/var/www/inventory/ResortApp/main.py"
$frontend_path = "/var/www/inventory/ResortApp/app/api/frontend.py"

Write-Host "Checking if frontend.py exists on server..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "ls -l '$frontend_path'"
if ($LASTEXITCODE -ne 0) {
    Write-Host "frontend.py MISSING on server. Uploading it too."
    scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\ResortApp\app\api\frontend.py" "${remote}:$frontend_path"
}

Write-Host "Deploying patched main.py..."
scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\ResortApp\main.py" "${remote}:$target_path"

Write-Host "Restarting Backend Service..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl restart inventory-resort.service"

Write-Host "Checking Service Status..."
Start-Sleep -Seconds 5
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl status inventory-resort.service --no-pager"
