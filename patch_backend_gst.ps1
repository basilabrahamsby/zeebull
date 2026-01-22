$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$localFile = "ResortApp\app\api\gst_reports.py"
$remotePath = "/home/basilabrahamaby/resort_app/app/api/gst_reports.py"

Write-Host "Uploading $localFile to $remote..."
scp -o StrictHostKeyChecking=no -i $pem $localFile "$remote`:$remotePath"

Write-Host "Restarting backend service..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl restart inventory-resort.service"
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo systemctl status inventory-resort.service | head -n 5"
