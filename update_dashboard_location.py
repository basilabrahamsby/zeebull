
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def update_dashboard_location():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    # Remove old /inventoryadmin/ block if exists
    new_lines = []
    skip = False
    for line in lines:
        if "location /inventoryadmin/" in line:
            skip = True
            continue
        if skip and line.strip() == "}":
            skip = False
            continue
        if skip:
            continue
        new_lines.append(line)

    # Now add /inventory/admin/ block
    final_lines = []
    inserted = False
    for line in new_lines:
        final_lines.append(line)
        if "listen 443 ssl;" in line and not inserted:
            final_lines.append("    location /inventory/admin/ {\n")
            final_lines.append("        alias /var/www/html/inventoryadmin/;\n")
            final_lines.append("        try_files $uri $uri/ /inventory/admin/index.html;\n")
            final_lines.append("        add_header Cache-Control \"no-cache, must-revalidate\";\n")
            final_lines.append("    }\n")
            inserted = True

    with open(NGINX_CONF, "w") as f:
        f.writelines(final_lines)
    
    print("Successfully updated Dashboard location to /inventory/admin/")

if __name__ == "__main__":
    update_dashboard_location()
