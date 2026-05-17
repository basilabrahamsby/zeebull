with open(r'd:\Zeebull\dasboard\src\pages\Bookings.jsx', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for idx in range(5190, 5260):
    if idx < len(lines):
        print(f"Line {idx+1}: {lines[idx].rstrip()}")
