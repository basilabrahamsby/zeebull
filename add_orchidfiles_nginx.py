
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def patch_nginx_orchid_files():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        lines = f.readlines()

    new_lines = []
    location_added = False
    
    # Check if /orchidfiles/ block already exists to avoid duplication
    log_exists = any("location /orchidfiles/ {" in line for line in lines)
    if log_exists:
        print("Block /orchidfiles/ already exists. Checking configuration...")
        # (Optional: Logic to update existing block if needed)
    
    for line in lines:
        new_lines.append(line)
        
        # Add the new /orchidfiles/ block before the final closing brace if it doesn't exist
        # Or better: insert it near other static file blocks
        if "location /inventoryfiles/ {" in line and not log_exists and not location_added:
             new_lines.append("\n    location /orchidfiles/ {\n")
             new_lines.append("        alias /var/www/inventory/ResortApp/;\n") # Serving base, image paths include uploads/
             # Wait, getMediaBaseUrl says orchidfiles is for media. 
             # And room images are stored in /uploads/rooms/...
             # So hitting /orchidfiles/rooms/abc.jpg -> /var/www/inventory/ResortApp/uploads/rooms/abc.jpg
             new_lines.append("        try_files $uri $uri/ =404;\n")
             new_lines.append("        add_header Cache-Control \"public, max-age=31536000\";\n")
             new_lines.append("    }\n")
             location_added = True

    if not location_added and not log_exists:
        # Fallback: Insert before last brace
        if new_lines[-1].strip() == "}":
             new_lines.insert(-1, "\n    location /orchidfiles/ {\n")
             new_lines.insert(-1, "        alias /var/www/inventory/ResortApp/;\n")
             new_lines.insert(-1, "        try_files $uri $uri/ =404;\n")
             new_lines.insert(-1, "        add_header Cache-Control \"public, max-age=31536000\";\n")
             new_lines.insert(-1, "    }\n")

    with open(NGINX_CONF, "w") as f:
        f.writelines(new_lines)
    
    print("Nginx configuration patched for /orchidfiles/.")

if __name__ == "__main__":
    patch_nginx_orchid_files()
