
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def fix_inventory_location():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    # Find and fix the /inventory/ location block
    new_lines = []
    in_inventory_block = False
    block_lines = []
    
    for line in lines:
        if 'location /inventory/' in line and '{' in line:
            in_inventory_block = True
            block_lines = [line]
        elif in_inventory_block:
            block_lines.append(line)
            if line.strip() == '}':
                # Reconstruct the block correctly
                new_lines.append('    location /inventory/ {\n')
                new_lines.append('        alias /var/www/html/inventory/;\n')
                new_lines.append('        try_files $uri $uri/ /inventory/index.html =404;\n')
                new_lines.append('        add_header Cache-Control "no-cache, no-store, must-revalidate";\n')
                new_lines.append('        add_header Pragma "no-cache";\n')
                new_lines.append('        add_header Expires "0";\n')
                new_lines.append('    }\n')
                in_inventory_block = False
                block_lines = []
        else:
            new_lines.append(line)

    with open(NGINX_CONF, "w") as f:
        f.writelines(new_lines)
    
    print("Successfully fixed /inventory/ location block.")

if __name__ == "__main__":
    fix_inventory_location()
