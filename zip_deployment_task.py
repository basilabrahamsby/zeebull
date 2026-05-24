import zipfile
import os
import shutil

def zip_dir(directory_path, zip_path, arcroot=""):
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(directory_path):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, directory_path)
                if arcroot:
                    rel_path = os.path.join(arcroot, rel_path)
                zip_arc_path = rel_path.replace(os.sep, '/')
                zipf.write(abs_path, zip_arc_path)
    print(f"Created {zip_path}")

# 1. Zip Dashboard Build
if os.path.exists('dasboard/build'):
    zip_dir('dasboard/build', 'dashboard_update.zip')
else:
    print("Warning: dasboard/build directory not found!")

# 2. Package Backend Files (files modified between 04dbe81 and 7b5efc9)
temp_dir = 'temp_deploy_task'
os.makedirs(os.path.join(temp_dir, 'app/api'), exist_ok=True)
os.makedirs(os.path.join(temp_dir, 'app/curd'), exist_ok=True)
os.makedirs(os.path.join(temp_dir, 'app/models'), exist_ok=True)
os.makedirs(os.path.join(temp_dir, 'app/schemas'), exist_ok=True)

# List of files to copy: (src, dest_rel)
files_to_copy = [
    ('ResortApp/checkout.py', 'checkout.py'),
    ('ResortApp/app/api/booking.py', 'app/api/booking.py'),
    ('ResortApp/app/api/branch.py', 'app/api/branch.py'),
    ('ResortApp/app/api/checkout.py', 'app/api/checkout.py'),
    ('ResortApp/app/api/packages.py', 'app/api/packages.py'),
    ('ResortApp/app/api/reports_module.py', 'app/api/reports_module.py'),
    ('ResortApp/app/curd/branch.py', 'app/curd/branch.py'),
    ('ResortApp/app/curd/packages.py', 'app/curd/packages.py'),
    ('ResortApp/app/models/branch.py', 'app/models/branch.py'),
    ('ResortApp/app/schemas/branch.py', 'app/schemas/branch.py'),
    ('ResortApp/app/schemas/checkout.py', 'app/schemas/checkout.py'),
]

for src, dest_rel in files_to_copy:
    dest_path = os.path.join(temp_dir, dest_rel)
    # Ensure parent dir exists
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    if os.path.exists(src):
        shutil.copy(src, dest_path)
        print(f"Copied {src} -> {dest_path}")
    else:
        print(f"Error: Source file {src} not found!")

# Zip the backend update package
zip_dir(temp_dir, 'backend_update.zip')

# Cleanup temp dir
shutil.rmtree(temp_dir)
print("Packaging complete.")
