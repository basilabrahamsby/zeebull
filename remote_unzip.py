import zipfile
import os

print("Extracting deploy.zip...")
try:
    with zipfile.ZipFile('deploy.zip', 'r') as zip_ref:
        zip_ref.extractall('.')
    print("Extraction complete.")
    
    # Verify critical files
    required = ['app/models/user.py', 'app/models/room.py', 'main.py']
    for f in required:
        if os.path.exists(f):
            print(f"Verified: {f}")
        else:
            print(f"MISSING: {f}")
            
except Exception as e:
    print(f"Error: {e}")
