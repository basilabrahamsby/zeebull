import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def final_fix():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    # Identify blocks to remove
    # We want to remove the old /inventory block (lines 59-63 in the downloaded version)
    # And the old /inventoryapi / inventory/ blocks if they were duplicates
    
    new_lines = []
    skip_until = -1
    
    for i, line in enumerate(lines):
        if i < skip_until:
            continue
            
        # Check for the /inventory block at old position
        if 'location /inventory {' in line or 'location /inventory ' in line:
             # Look ahead to see if it's the one at line 59
             # Usually it's followed by alias /var/www/html/inventory/
             skip_until = i + 1
             while skip_until < len(lines) and '}' not in lines[skip_until]:
                 skip_until += 1
             skip_until += 1 # skip the closing brace
             continue
             
        new_lines.append(line)

    with open(NGINX_CONF, "w") as f:
        f.writelines(new_lines)
    
    print("Successfully cleaned up Nginx config.")

if __name__ == "__main__":
    final_fix()
