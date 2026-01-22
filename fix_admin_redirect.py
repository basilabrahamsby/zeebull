
import os
import sys

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def patch_nginx():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    new_lines = []
    redirect_added = False
    
    for line in lines:
        # Detect where to insert the redirect (before the admin location block)
        if "location /orchid/admin/ {" in line and not redirect_added:
            new_lines.append("    # Redirect /orchid/admin to /orchid/admin/\n")
            new_lines.append("    location = /orchid/admin {\n")
            new_lines.append("        return 301 /orchid/admin/;\n")
            new_lines.append("    }\n\n")
            redirect_added = True
            
        # Clean up try_files in /orchid/ block?
        # Only if we are in that block.
        if "try_files $uri $uri/ /orchid/index.html =404;" in line:
            new_lines.append(line.replace(" =404", "")) # Remove =404, leave /orchid/index.html
        else:
            new_lines.append(line)

    with open(NGINX_CONF, "w") as f:
        f.writelines(new_lines)
    
    print("Nginx configuration patched.")

if __name__ == "__main__":
    patch_nginx()
