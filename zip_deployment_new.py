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

# Dashboard - Use the standard build directory
zip_dir('dasboard/build', 'dashboard_update.zip')

# Backend
os.makedirs('temp_deploy_fix/app/api', exist_ok=True)
os.makedirs('temp_deploy_fix/app/core', exist_ok=True)
os.makedirs('temp_deploy_fix/app/models', exist_ok=True)
os.makedirs('temp_deploy_fix/app/schemas', exist_ok=True)

# Copy updated files
shutil.copy('ResortApp/app/api/room.py', 'temp_deploy_fix/app/api/room.py')
shutil.copy('ResortApp/app/api/checkout.py', 'temp_deploy_fix/app/api/checkout.py')
shutil.copy('ResortApp/app/api/channel_manager.py', 'temp_deploy_fix/app/api/channel_manager.py')
shutil.copy('ResortApp/app/api/booking.py', 'temp_deploy_fix/app/api/booking.py')
shutil.copy('ResortApp/app/core/aiosell_triggers.py', 'temp_deploy_fix/app/core/aiosell_triggers.py')
shutil.copy('ResortApp/app/models/room.py', 'temp_deploy_fix/app/models/room.py')
shutil.copy('ResortApp/app/schemas/room_type.py', 'temp_deploy_fix/app/schemas/room_type.py')

# Include the force sync script at the root of the update
shutil.copy('ResortApp/force_aiosell_sync.py', 'temp_deploy_fix/force_aiosell_sync.py')

zip_dir('temp_deploy_fix', 'backend_update.zip')

shutil.rmtree('temp_deploy_fix')
