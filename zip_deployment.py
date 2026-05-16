import zipfile
import os

def zip_dir(directory_path, zip_path, arcroot=""):
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(directory_path):
            for file in files:
                abs_path = os.path.join(root, file)
                # Use forward slashes for the archive path
                rel_path = os.path.relpath(abs_path, directory_path)
                if arcroot:
                    rel_path = os.path.join(arcroot, rel_path)
                zip_arc_path = rel_path.replace(os.sep, '/')
                zipf.write(abs_path, zip_arc_path)
    print(f"Created {zip_path}")

# Dashboard
zip_dir('dasboard/build', 'dashboard_update.zip')

# Backend
# Gather files into a temp structure with forward slashes
os.makedirs('temp_deploy_fix/app/api', exist_ok=True)
os.makedirs('temp_deploy_fix/app/core', exist_ok=True)
os.makedirs('temp_deploy_fix/app/models', exist_ok=True)
os.makedirs('temp_deploy_fix/app/schemas', exist_ok=True)

import shutil
shutil.copy('ResortApp/app/api/room.py', 'temp_deploy_fix/app/api/room.py')
shutil.copy('ResortApp/app/core/aiosell_triggers.py', 'temp_deploy_fix/app/core/aiosell_triggers.py')
shutil.copy('ResortApp/app/models/room.py', 'temp_deploy_fix/app/models/room.py')
shutil.copy('ResortApp/app/schemas/room_type.py', 'temp_deploy_fix/app/schemas/room_type.py')

zip_dir('temp_deploy_fix', 'backend_update.zip')

shutil.rmtree('temp_deploy_fix')
