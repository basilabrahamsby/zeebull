
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def update_api_path():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        content = f.read()

    # Replace /inventoryapi/ with /orchidapi/
    content = content.replace('location /inventoryapi/', 'location /orchidapi/')

    with open(NGINX_CONF, "w") as f:
        f.write(content)
    
    print("Successfully updated API path from inventoryapi to orchidapi.")

if __name__ == "__main__":
    update_api_path()
