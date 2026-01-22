
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def add_nocache_headers():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        content = f.read()

    # Check if already has no-cache for /inventory/
    if 'location /inventory/' in content and 'no-cache' in content:
        print("No-cache headers already present.")
        return

    lines = content.split('\n')
    final_lines = []
    in_inventory_block = False
    
    for i, line in enumerate(lines):
        final_lines.append(line)
        
        if 'location /inventory/' in line and '{' in line:
            in_inventory_block = True
        elif in_inventory_block and 'alias' in line:
            # Add no-cache headers right after alias
            final_lines.append('        add_header Cache-Control "no-cache, no-store, must-revalidate";')
            final_lines.append('        add_header Pragma "no-cache";')
            final_lines.append('        add_header Expires "0";')
            in_inventory_block = False

    with open(NGINX_CONF, "w") as f:
        f.write('\n'.join(final_lines))
    
    print("Successfully added no-cache headers to /inventory/ location.")

if __name__ == "__main__":
    add_nocache_headers()
