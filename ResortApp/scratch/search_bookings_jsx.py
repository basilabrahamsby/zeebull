import re

with open(r'd:\Zeebull\dasboard\src\pages\Bookings.jsx', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print("Searching for check-in save / onSave implementation:")
for i, line in enumerate(lines):
    if 'check-in' in line.lower() or 'onsave' in line.lower() or 'amenityallocation' in line.lower():
        print(f"Line {i+1}: {line.strip()}")
