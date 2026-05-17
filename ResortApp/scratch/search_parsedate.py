import os

search_dir = r"d:\Zeebull\Mobile\employee\lib"

print("Searching for _parseDate in lib:")
for root, dirs, files in os.walk(search_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                if '_parseDate' in content or 'parseDate' in content:
                    f.seek(0)
                    lines = f.readlines()
                    for idx, line in enumerate(lines):
                        if '_parsedate' in line.lower() or 'parsedate' in line.lower():
                            print(f"File: {os.path.basename(path)} Line {idx+1}: {line.strip()}")
            except Exception as e:
                pass
