$serverIP = "136.113.93.47"
$username = "basilabrahamaby"
$sshKey = "$env:USERPROFILE\.ssh\gcp_key"

Write-Host "Force Restarting Backend..."
ssh -i $sshKey "${username}@${serverIP}" "sudo systemctl restart inventory-resort.service"

Write-Host "Waiting 5s..."
Start-Sleep -Seconds 5

Write-Host "Checking Status..."
ssh -i $sshKey "${username}@${serverIP}" "sudo systemctl status inventory-resort.service"
