import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def final_fix():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    new_lines = []
    skip = False
    for line in lines:
        # Skip existing inventory or inventoryapi blocks
        if 'location /inventory/' in line or 'location /inventoryapi/' in line:
            skip = True
            continue
        if skip and line.strip() == "}":
            skip = False
            continue
        if skip:
            continue
        new_lines.append(line)

    # Re-insert blocks at the start of the server block (after listen)
    final_lines = []
    inserted = False
    for line in new_lines:
        final_lines.append(line)
        if "listen 443 ssl;" in line and not inserted:
            # Add inventoryapi block
            final_lines.append("\n    location /inventoryapi/ {\n")
            final_lines.append("        proxy_pass http://127.0.0.1:8011/;\n")
            final_lines.append("        proxy_set_header Host $host;\n")
            final_lines.append("        proxy_set_header X-Real-IP $remote_addr;\n")
            final_lines.append("        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n")
            final_lines.append("        proxy_set_header X-Forwarded-Proto $scheme;\n")
            final_lines.append("        add_header Cache-Control \"no-cache, no-store, must-revalidate\";\n")
            final_lines.append("    }\n")
            
            # Add inventory block
            final_lines.append("\n    location /inventory/ {\n")
            final_lines.append("        alias /var/www/html/inventory/;\n")
            final_lines.append("        try_files $uri $uri/ /inventory/index.html =404;\n")
            final_lines.append("        add_header Cache-Control \"no-cache, no-store, must-revalidate\";\n")
            final_lines.append("        add_header Pragma \"no-cache\";\n")
            final_lines.append("        add_header Expires \"0\";\n")
            final_lines.append("    }\n")
            inserted = True

    with open(NGINX_CONF, "w") as f:
        f.writelines(final_lines)
    
    print("Successfully re-aligned Nginx blocks.")

if __name__ == "__main__":
    final_fix()
