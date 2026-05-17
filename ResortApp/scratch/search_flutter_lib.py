import os

search_dir = r"d:\Zeebull\Mobile\employee\lib"
keywords = ["DateTime", ".toLocal()", "parse("]

print("Searching for date parsing in Flutter app lib:")
for root, dirs, files in os.walk(search_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Check for keywords
                found = []
                for kw in keywords:
                    if kw in content:
                        found.append(kw)
                
                if found:
                    # Search specific lines
                    f.seek(0)
                    lines = f.readlines()
                    for idx, line in enumerate(lines):
                        if any(kw in line for kw in keywords) and ('created_at' in line.lower() or 'createdat' in line.lower() or 'time' in line.lower() or 'date' in line.lower()):
                            print(f"File: {os.path.basename(path)} Line {idx+1}: {line.strip()}")
            except Exception as e:
                pass
