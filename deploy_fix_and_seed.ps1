$pem = "$env:USERPROFILE\.ssh\gcp_key"
$remote = "basilabrahamaby@136.113.93.47"
$targetDir = "/var/www/inventory/ResortApp"
$tempDir = "/home/basilabrahamaby"

# Upload gst_reports.py
Write-Host "Uploading gst_reports.py to temp..."
scp -o StrictHostKeyChecking=no -i $pem "ResortApp/app/api/gst_reports.py" "$remote`:$tempDir/gst_reports.py"

# Upload seed/migrate scripts
Write-Host "Uploading seed scripts to temp..."
scp -o StrictHostKeyChecking=no -i $pem "ResortApp/migrate_create_accounting_tables.py" "$remote`:$tempDir/migrate_create_accounting_tables.py"
scp -o StrictHostKeyChecking=no -i $pem "ResortApp/seed_accounting_data.py" "$remote`:$tempDir/seed_accounting_data.py"

# Execute remote commands
# Note: Using single quotes for python commands inside the big string needs care.
$cmd = "
    echo 'Moving files...'
    sudo cp $tempDir/gst_reports.py $targetDir/app/api/gst_reports.py
    sudo cp $tempDir/migrate_create_accounting_tables.py $targetDir/migrate_create_accounting_tables.py
    sudo cp $tempDir/seed_accounting_data.py $targetDir/seed_accounting_data.py
    
    echo 'Setting permissions...'
    sudo chown www-data:www-data $targetDir/app/api/gst_reports.py
    sudo chown www-data:www-data $targetDir/migrate_create_accounting_tables.py
    sudo chown www-data:www-data $targetDir/seed_accounting_data.py
    
    echo 'Restarting Service...'
    sudo systemctl restart inventory-resort.service
    
    echo 'Running Migration...'
    cd $targetDir
    if [ -d venv ]; then
        sudo ./venv/bin/python3 migrate_create_accounting_tables.py
        echo 'Running Seeding...'
        sudo ./venv/bin/python3 seed_accounting_data.py
    elif [ -d .venv ]; then
        sudo ./.venv/bin/python3 migrate_create_accounting_tables.py
        echo 'Running Seeding...'
        sudo ./.venv/bin/python3 seed_accounting_data.py
    else
        echo 'No venv found. Skipping python scripts.'
    fi
"

Write-Host "Executing remote deployment..."
ssh -o StrictHostKeyChecking=no -i $pem $remote $cmd
