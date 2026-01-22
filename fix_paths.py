#!/usr/bin/env python3
import os
import shutil

os.chdir('/var/www/inventory/ResortApp')

# Find all files with backslashes and reorganize
for root, dirs, files in os.walk('.'):
    for file in files:
        if '\\' in file:
            filepath = os.path.join(root, file)
            parts = file.split('\\')
            if len(parts) > 1:
                # Create proper directory structure
                dir_path = os.path.join(root, *parts[:-1])
                os.makedirs(dir_path, exist_ok=True)
                # Move file
                new_path = os.path.join(dir_path, parts[-1])
                try:
                    shutil.move(filepath, new_path)
                    print(f"Moved: {file} -> {new_path}")
                except Exception as e:
                    print(f"Error moving {file}: {e}")

print("Done fixing paths!")
