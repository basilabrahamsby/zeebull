$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking backend service logs (last 50 lines)..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo journalctl -u inventory-resort.service -n 50 --no-pager"
