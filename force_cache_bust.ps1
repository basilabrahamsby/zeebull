$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"

Write-Host "Checking what the browser is actually loading..."
Write-Host "`n1. Current index.html on server:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "cat /var/www/html/inventory/index.html | grep -o 'src=\"[^\"]*\.js\"' | head -n 3"

Write-Host "`n2. Checking if Service Worker is caching old files:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "grep -r 'serviceWorker' /var/www/html/inventory/ 2>/dev/null | head -n 2"

Write-Host "`n3. Let's add a version query parameter to force cache bust..."
Write-Host "   Adding ?v=20260109 to all asset URLs..."

# Create a script to add version parameter
$versionScript = @'
#!/bin/bash
cd /var/www/html/inventory
# Add version parameter to index.html script tags
sed -i 's/src="\([^"]*\.js\)"/src="\1?v=20260109"/g' index.html
sed -i 's/href="\([^"]*\.css\)"/href="\1?v=20260109"/g' index.html
echo "Version parameters added to index.html"
'@

$versionScript | Out-File -FilePath "c:\releasing\New Orchid\add_version.sh" -Encoding ASCII

scp -o StrictHostKeyChecking=no -i $pem "c:\releasing\New Orchid\add_version.sh" "${remote}:~/add_version.sh"
ssh -o StrictHostKeyChecking=no -i $pem $remote "chmod +x ~/add_version.sh && sudo ~/add_version.sh"

Write-Host "`n4. Verifying changes:"
ssh -o StrictHostKeyChecking=no -i $pem $remote "cat /var/www/html/inventory/index.html | grep -o 'src=\"[^\"]*\.js[^\"]*\"' | head -n 3"

Write-Host "`n✅ Cache-busting version parameters added!"
Write-Host "Please refresh the page now (Ctrl+F5)"
