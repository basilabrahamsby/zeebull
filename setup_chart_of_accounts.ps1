$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$remoteDir = "/home/basilabrahamaby/resort_app"

$files = @(
    "ResortApp/migrate_create_accounting_tables.py",
    "ResortApp/seed_accounting_data.py"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Uploading $file..."
        scp -o StrictHostKeyChecking=no -i $pem $file "$remote`:$remoteDir/$(Split-Path $file -Leaf)"
    } else {
        Write-Error "File not found: $file"
        exit 1
    }
}

Write-Host "Running Migration..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "cd $remoteDir && ./venv/bin/python3 migrate_create_accounting_tables.py"

Write-Host "Running Seeding..."
ssh -o StrictHostKeyChecking=no -i $pem $remote "cd $remoteDir && ./venv/bin/python3 seed_accounting_data.py"
