with open(r"d:\Zeebull\ResortApp\app\api\checkout.py", "r", encoding="utf-8") as f:
    lines = f.readlines()

for idx, line in enumerate(lines):
    if "router." in line or "def " in line:
        if idx < 100 or "checkout" in line or "inventory" in line or "check" in line:
            print(f"{idx+1}: {line.strip()}")
