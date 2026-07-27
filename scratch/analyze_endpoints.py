import re

file_path = r"c:\releasing\New Orchid\ResortApp\app\api\checkout.py"

with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# Let's find all `@router...` and the following `def ...`
pattern = r"(@router\.[a-z]+\([^)]+\))\s*\n\s*def\s+([a-zA-Z0-9_]+)\("
matches = re.findall(pattern, content)

print(f"Found {len(matches)} endpoint decorators followed by def:")
for dec, func in matches[:50]:
    print(f"  {dec} -> def {func}")

# Let's search for "def " generally to see what functions are in it
pattern_def = r"def\s+([a-zA-Z0-9_]+)\("
all_defs = re.findall(pattern_def, content)
print(f"\nTotal functions defined: {len(all_defs)}")
print("First 20 functions:")
for name in all_defs[:20]:
    print(f"  - {name}")
