
import os
import sys

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def fix_config():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    # cleaning up old bad insertion
    new_lines = []
    skip = False
    for line in lines:
        stripped = line.strip()
        if "location /inventoryapi/" in line:
            skip = True
            continue
        if skip and stripped == "}":
            skip = False
            continue
        if skip:
            continue
        # Also catch standalone junk if logic failed
        if "011/;" in line: 
            continue 
            
        new_lines.append(line)

    # Now insert correct block
    final_lines = []
    inserted = False
    for line in new_lines:
        final_lines.append(line)
        if "listen 443 ssl;" in line and not inserted:
            final_lines.append("    location /inventoryapi/ {\n")
            final_lines.append("        proxy_pass http://127.0.0.1:8011/;\n")
            final_lines.append("        proxy_set_header Host $host;\n")
            final_lines.append("        proxy_set_header X-Real-IP $remote_addr;\n")
            final_lines.append("        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n")
            final_lines.append("        proxy_set_header X-Forwarded-Proto $scheme;\n")
            final_lines.append("    }\n")
            inserted = True

    with open(NGINX_CONF, "w") as f:
        f.writelines(final_lines)
    
    print("Successfully patched Nginx config.")

if __name__ == "__main__":
    fix_config()
