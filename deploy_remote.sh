#!/bin/bash
TARGET_DIR="/var/www/inventory/ResortApp"
TEMP_DIR="/home/basilabrahamaby"

echo "Moving files..."
sudo cp $TEMP_DIR/gst_reports.py $TARGET_DIR/app/api/gst_reports.py
sudo cp $TEMP_DIR/migrate_create_accounting_tables.py $TARGET_DIR/migrate_create_accounting_tables.py
sudo cp $TEMP_DIR/seed_accounting_data.py $TARGET_DIR/seed_accounting_data.py

echo "Setting permissions..."
sudo chown www-data:www-data $TARGET_DIR/app/api/gst_reports.py
sudo chown www-data:www-data $TARGET_DIR/migrate_create_accounting_tables.py
sudo chown www-data:www-data $TARGET_DIR/seed_accounting_data.py

echo "Restarting Service..."
sudo systemctl restart inventory-resort.service

echo "Running Migration..."
cd $TARGET_DIR
if [ -d venv ]; then
    sudo ./venv/bin/python3 migrate_create_accounting_tables.py
    echo "Running Seeding..."
    sudo ./venv/bin/python3 seed_accounting_data.py
elif [ -d .venv ]; then
    sudo ./.venv/bin/python3 migrate_create_accounting_tables.py
    echo "Running Seeding..."
    sudo ./.venv/bin/python3 seed_accounting_data.py
else
    echo "No venv found. Skipping python scripts."
fi
