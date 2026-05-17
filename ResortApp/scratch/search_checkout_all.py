import os

search_dir = r"d:\Zeebull\ResortApp\app"

print("Searching for checkout_request in app:")
for root, dirs, files in os.walk(search_dir):
    for file in files:
        if file.endswith('.py'):
            path = os.path.join(root, file)
            try:
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                if 'checkout-request' in content.lower() or 'checkout_request' in content.lower():
                    f.seek(0)
                    lines = f.readlines()
                    for idx, line in enumerate(lines):
                        if 'checkout-request' in line.lower() or 'checkout_request' in line.lower():
                            print(f"File: {os.path.basename(path)} Line {idx+1}: {line.strip()}")
            except Exception as e:
                pass
