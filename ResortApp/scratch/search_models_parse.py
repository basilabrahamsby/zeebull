import os

search_dir = r"d:\Zeebull\Mobile\employee\lib\data\models"

print("Searching for parse( in data/models:")
for root, dirs, files in os.walk(search_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    lines = f.readlines()
                    for idx, line in enumerate(lines):
                        if 'parse(' in line.lower():
                            print(f"File: {os.path.basename(path)} Line {idx+1}: {line.strip()}")
            except Exception as e:
                pass
