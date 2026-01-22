$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Adding version parameter to force cache refresh..."

# Simple bash script to add version
$script = 'cd /var/www/html/inventory && sudo sed -i "s/\.js\"/\.js?v=20260109\"/g" index.html && sudo sed -i "s/\.css\"/\.css?v=20260109\"/g" index.html'

ssh -o StrictHostKeyChecking=no -i $pem $remote $script

Write-Host "`nDone! Please refresh the Userend page now."
