import os
import shutil

target_dir = "/var/www/html/orchidadmin/"
os.chdir(target_dir)

for name in os.listdir("."):
    if "\\" in name:
        new_name = name.replace("\\", "/")
        new_path = os.path.join(".", new_name)
        
        # Ensure target directory exists
        os.makedirs(os.path.dirname(new_path), exist_ok=True)
        
        print(f"Moving {name} to {new_path}")
        # Need to handle if target already exists or logic for nested backslashes
        # But usually 'static\js\main.js' just becomes 'static/js/main.js'
        shutil.move(name, new_path)
