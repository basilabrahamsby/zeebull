$serverIP = "136.113.93.47"
$username = "basilabrahamaby"
$sshKey = "$env:USERPROFILE\.ssh\gcp_key"

Write-Host "Checking Backend Service Status..."
ssh -i $sshKey "${username}@${serverIP}" "sudo systemctl status inventory-resort.service"

Write-Host "`nChecking Service Logs..."
ssh -i $sshKey "${username}@${serverIP}" "sudo journalctl -u inventory-resort.service -n 50 --no-pager"

Write-Host "`nChecking Nginx Status..."
ssh -i $sshKey "${username}@${serverIP}" "sudo systemctl status nginx"
