with open(r'd:\Zeebull\ResortApp\app\api\booking.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print("Searching for amenityAllocation in booking.py:")
for i, line in enumerate(lines):
    if 'amenityallocation' in line.lower():
        print(f"Line {i+1}: {line.strip()}")
