import zipfile
import os

print("Creating deploy_v2.zip...")
try:
    with zipfile.ZipFile('deploy_v2.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add main.py
        if os.path.exists('ResortApp/main.py'):
            zipf.write('ResortApp/main.py', arcname='main.py')
            print("Added main.py")
        
        # Add app directory
        for root, dirs, files in os.walk('ResortApp/app'):
            for file in files:
                if '__pycache__' in root:
                    continue
                if file.endswith('.pyc'):
                    continue
                    
                file_path = os.path.join(root, file)
                # Calculate arcname to be relative to ResortApp/ (so 'app/models/room.py')
                # root is like 'ResortApp/app/models'
                # relpath from 'ResortApp' -> 'app/models'
                rel_path = os.path.relpath(file_path, 'ResortApp')
                zipf.write(file_path, arcname=rel_path)
                # print(f"Added {rel_path}")

    print("Zip created.")
    
    # Verify
    print("Verifying zip...")
    with zipfile.ZipFile('deploy_v2.zip', 'r') as zipf:
        namelist = zipf.namelist()
        if 'app/models/room.py' in namelist:
            print("Verified: app/models/room.py is present.")
        else:
            print("ERROR: app/models/room.py is MISSING in zip!")

except Exception as e:
    print(f"Error: {e}")
