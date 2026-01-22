
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def update_paths():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        content = f.read()

    # Replace /inventory/ with /orchid/
    # Replace /inventory/admin/ with /orchid/admin/
    # Replace /inventoryadmin/ with /orchidadmin/
    
    # Careful with order to avoid double replacements
    content = content.replace('location /inventory/admin/', 'location /orchid/admin/')
    content = content.replace('location /inventory/', 'location /orchid/')
    content = content.replace('/inventory/index.html', '/orchid/index.html')
    content = content.replace('/var/www/html/inventory/', '/var/www/html/orchid/')
    content = content.replace('/var/www/html/inventoryadmin/', '/var/www/html/orchidadmin/')

    with open(NGINX_CONF, "w") as f:
        f.write(content)
    
    print("Successfully updated Nginx paths from inventory to orchid.")

if __name__ == "__main__":
    update_paths()
