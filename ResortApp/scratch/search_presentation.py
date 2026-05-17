import os

search_dir = r"d:\Zeebull\Mobile\employee\lib\presentation"

print("Searching for datetime / formatting fields in presentation:")
for root, dirs, files in os.walk(search_dir):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Check for keywords case-insensitively
                terms = ['created_at', 'completed_at', 'createdat', 'completedat', 'created at', 'completed at', 'dateformat', 'intl']
                if any(t in content.lower() for t in terms):
                    f.seek(0)
                    lines = f.readlines()
                    for idx, line in enumerate(lines):
                        if any(t in line.lower() for t in terms):
                            print(f"File: {os.path.basename(path)} Line {idx+1}: {line.strip()}")
            except Exception as e:
                pass
