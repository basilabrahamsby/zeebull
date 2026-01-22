#!/bin/bash
set -e
sudo -u postgres psql -c "CREATE USER orchid_user WITH PASSWORD 'admin123';" || true
sudo -u postgres psql -c "CREATE DATABASE orchid_resort OWNER orchid_user;" || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE orchid_resort TO orchid_user;" || true

cd /var/www/inventory/ResortApp
echo "Running Migrations..."
sudo ./venv/bin/alembic upgrade head
echo "DB Setup Complete"
