#!/bin/bash
CONFIG_FILE="/etc/nginx/sites-enabled/pomma"

# Backup
sudo cp $CONFIG_FILE ${CONFIG_FILE}.bak

# Remove any existing /inventoryapi/ block (it might be in wrong place)
# We delete lines matching "location /inventoryapi/" and the following 7 lines?
# Safer to just append correct one and reload? Nginx might warn about duplicates or ignore.
# If duplicate location inside same server -> Error.
# If location outside server -> Error or ignored?
# My previous script appended it to END (outside server block likely).

# We will INSERT correct block inside SSL server block.
# Anchor: "ssl_certificate" or "server_name".
# We'll use "server_name www.teqmates.com" as anchor (or strict regex).

BLOCK="
    location /inventoryapi/ {
        proxy_pass http://127.0.0.1:8011/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
"

# Check if block exists inside valid context? 
# We'll validly insert it after 'ssl_certificate' line (usually present in 443 block).
# If multiple ssl_certificate lines? (Usually one).

# Insert using awk or py? sed is brittle with multi-lines.
# We'll simply append it BEFORE the last closing brace of the HTTPS block?
# If we have nested blocks, last brace is risky.

# Let's search for "listen 443 ssl;" line.
# Insert AFTER that line.

sudo sed -i '/listen 443 ssl;/r /dev/stdin' $CONFIG_FILE <<< "$BLOCK"

echo "Inserted location /inventoryapi/ block."

# Reload
sudo nginx -t && sudo systemctl reload nginx
