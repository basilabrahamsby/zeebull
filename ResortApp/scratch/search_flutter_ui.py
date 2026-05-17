import os

search_dir = r"d:\Zeebull\Mobile\employee\lib"

print("Searching for 'CREATED AT' in Flutter app lib:")
for root, dirs, files in os.walk(search_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if 'CREATED AT' in content or 'created_at' in content or 'completed_at' in content:
                    # Find specific lines
                    f.seek(0)
                    lines = f.readlines()
                    for idx, line in enumerate(lines):
                        if any(term in line for term in ['CREATED AT', 'COMPLETED AT', 'created_at', 'completed_at']):
                            print(f"File: {os.path.basename(path)} Line {idx+1}: {line.strip()}")
            except Exception as e:
                pass
