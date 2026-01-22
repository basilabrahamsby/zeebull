#!/bin/bash
# Remove existing inventoryapi block using range
sudo sed -i '/location \/inventoryapi\/ {/,/    }/d' /etc/nginx/sites-enabled/pomma

# Insert before the last closing brace
sudo sed -i '$d' /etc/nginx/sites-enabled/pomma
    
sudo tee -a /etc/nginx/sites-enabled/pomma > /dev/null <<EOT
    location /inventoryapi/ {
        proxy_pass http://127.0.0.1:8011/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOT
sudo nginx -t && sudo systemctl reload nginx
