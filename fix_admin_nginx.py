
import os

NGINX_CONF = "/etc/nginx/sites-enabled/pomma"

def fix_admin_path():
    if not os.path.exists(NGINX_CONF):
        print(f"Error: {NGINX_CONF} not found.")
        return

    with open(NGINX_CONF, "r") as f:
        content = f.read()

    # Fix the duplicate/incorrect try_files in the admin block
    content = content.replace('/inventory/admin/index.html', '/orchid/admin/index.html')

    with open(NGINX_CONF, "w") as f:
        f.write(content)
    
    print("Successfully fixed Nginx admin paths.")

if __name__ == "__main__":
    fix_admin_path()
