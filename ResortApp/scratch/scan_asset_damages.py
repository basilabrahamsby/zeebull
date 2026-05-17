with open(r"d:\Zeebull\ResortApp\app\api\checkout.py", "r", encoding="utf-8") as f:
    lines = f.readlines()

for idx, line in enumerate(lines):
    if "asset_damages" in line:
        print(f"{idx+1}: {line.strip()}")
