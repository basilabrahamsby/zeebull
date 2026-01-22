#!/bin/bash
sudo sed -i 's|"/inventory/|"/inventory/admin/|g' /var/www/html/inventory/admin/index.html
echo "Index paths fixed"
