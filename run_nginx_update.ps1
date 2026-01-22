$serverIP = "136.113.93.47"
$username = "basilabrahamaby"
$sshKey = "$env:USERPROFILE\.ssh\gcp_key"

Write-Host "Uploading Nginx Update Script..."
scp -i $sshKey "c:\releasing\New Orchid\update_nginx.sh" "${username}@${serverIP}:~/orchid-repo/"

Write-Host "Running Nginx Update..."
ssh -i $sshKey "${username}@${serverIP}" "chmod +x ~/orchid-repo/update_nginx.sh && sudo ~/orchid-repo/update_nginx.sh"
