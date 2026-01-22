$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking backend error logs (last 100 lines)..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo journalctl -u inventory-resort.service -n 100 --no-pager | grep -A 5 -B 5 -i 'error\|exception\|traceback\|500'"

Write-Host "`n`nChecking Nginx error logs..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "sudo tail -n 50 /var/log/nginx/error.log"
