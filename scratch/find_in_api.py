file_path = r"c:\releasing\New Orchid\ResortApp\app\api\checkout.py"

with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

for idx, line in enumerate(lines):
    if '@router.get("/{room_number}"' in line or '@router.get("/' in line:
        print(f"Line {idx+1}: {line.strip()[:100]}")
