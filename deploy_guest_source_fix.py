import zipfile
import os
import shutil

def zip_dir(directory_path, zip_path, exclude_dirs=None):
    exclude_dirs = exclude_dirs or []
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(directory_path):
            # Skip excluded directories
            dirs[:] = [d for d in dirs if d not in exclude_dirs]
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, directory_path)
                zip_arc_path = rel_path.replace(os.sep, '/')
                zipf.write(abs_path, zip_arc_path)
    size_mb = os.path.getsize(zip_path) / (1024*1024)
    print(f"  Created {zip_path} ({size_mb:.1f} MB)")

print("=" * 50)
print("Packaging: Guest Source Fix Deployment")
print("=" * 50)

# 1. Package Dashboard build
print("\n[1/3] Packaging Admin Dashboard build...")
zip_dir('dasboard/build', 'zeebull_admin.zip')

# 2. Package Userend build
print("[2/3] Packaging User-End (Website) build...")
zip_dir('userend/build', 'zeebull_userend.zip')

# 3. Package backend changes (only changed files)
print("[3/3] Packaging Backend changes...")
temp_dir = 'temp_guest_fix'
os.makedirs(os.path.join(temp_dir, 'app/api'), exist_ok=True)

backend_files = [
    ('ResortApp/app/api/booking.py', 'app/api/booking.py'),
]

for src, dest_rel in backend_files:
    dest_path = os.path.join(temp_dir, dest_rel)
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    if os.path.exists(src):
        shutil.copy(src, dest_path)
        print(f"  Copied {src}")
    else:
        print(f"  ERROR: {src} not found!")

zip_dir(temp_dir, 'backend_guest_fix.zip')
shutil.rmtree(temp_dir)

print("\n" + "=" * 50)
print("All packages ready for upload!")
print("  zeebull_admin.zip       -> Dashboard")
print("  zeebull_userend.zip     -> User Website")
print("  backend_guest_fix.zip   -> Backend API")
print("=" * 50)
