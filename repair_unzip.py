import zipfile
import os
import sys

if len(sys.argv) < 3:
    print("Usage: repair_unzip.py <zipfile> <destination>")
    sys.exit(1)

zip_path = sys.argv[1]
dest = sys.argv[2]

print(f"Extracting {zip_path} to {dest}")

with zipfile.ZipFile(zip_path, 'r') as z:
    for f in z.infolist():
        # Fix backslashes
        name = f.filename.replace('\\', '/')
        
        # Skip directories (makedirs handles parents)
        if name.endswith('/'):
            continue
            
        out_path = os.path.join(dest, name)
        
        # Ensure parent dir exists
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        
        # Extract file
        with open(out_path, 'wb') as outfile, z.open(f) as infile:
            outfile.write(infile.read())

print("Extraction Complete")
