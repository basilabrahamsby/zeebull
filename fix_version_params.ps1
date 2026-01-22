$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Fixing malformed version parameters..."

# Restore index.html and apply version correctly
$fixScript = @'
cd /var/www/html/inventory
# First, remove the broken version parameters
sudo sed -i 's/\.js?v=20260109/\.js/g' index.html
sudo sed -i 's/\.css?v=20260109/\.css/g' index.html
# Now add them correctly at the end of the full path
sudo sed -i 's/\(src="[^"]*\.js\)"/\1?v=20260109"/g' index.html
sudo sed -i 's/\(href="[^"]*\.css\)"/\1?v=20260109"/g' index.html
echo "Fixed version parameters"
'@

$fixScript | ssh -o StrictHostKeyChecking=no -i $pem $remote "bash -s"

Write-Host "`nVerifying fix..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep 'main.*\.js' /var/www/html/inventory/index.html | head -n 2"

Write-Host "`n✅ Fixed! Please refresh the page now (Ctrl+F5)"
