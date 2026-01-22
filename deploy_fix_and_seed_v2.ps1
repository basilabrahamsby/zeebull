$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$tempDir = "/home/basilabrahamaby"

# Upload files
Write-Host "Uploading files..."
scp -o StrictHostKeyChecking=no -i $pem "ResortApp/app/api/gst_reports.py" "$remote`:$tempDir/gst_reports.py"
scp -o StrictHostKeyChecking=no -i $pem "ResortApp/migrate_create_accounting_tables.py" "$remote`:$tempDir/migrate_create_accounting_tables.py"
scp -o StrictHostKeyChecking=no -i $pem "ResortApp/seed_accounting_data.py" "$remote`:$tempDir/seed_accounting_data.py"
scp -o StrictHostKeyChecking=no -i $pem "deploy_remote.sh" "$remote`:$tempDir/deploy_remote.sh"

# Run remote script
Write-Host "Executing remote script..."
# Use sed to remove CR characters in case of Windows upload
$cmd = "sed -i 's/\r$//' $tempDir/deploy_remote.sh && chmod +x $tempDir/deploy_remote.sh && $tempDir/deploy_remote.sh"
ssh -o StrictHostKeyChecking=no -i $pem $remote $cmd
