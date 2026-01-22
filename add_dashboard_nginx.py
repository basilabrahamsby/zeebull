
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def add_dashboard_location():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    # Check if already exists
    for line in lines:
        if "location /inventoryadmin/" in line:
            print("Dashboard location block already exists.")
            return

    # Find where to insert (after listen 443 ssl;)
    final_lines = []
    inserted = False
    for line in lines:
        final_lines.append(line)
        if "listen 443 ssl;" in line and not inserted:
            final_lines.append("    location /inventoryadmin/ {\n")
            final_lines.append("        alias /var/www/html/inventoryadmin/;\n")
            final_lines.append("        try_files $uri $uri/ /inventoryadmin/index.html;\n")
            final_lines.append("        add_header Cache-Control \"no-cache, must-revalidate\";\n")
            final_lines.append("    }\n")
            inserted = True

    with open(NGINX_CONF, "w") as f:
        f.writelines(final_lines)
    
    print("Successfully added Dashboard location block to Nginx config.")

if __name__ == "__main__":
    add_dashboard_location()
