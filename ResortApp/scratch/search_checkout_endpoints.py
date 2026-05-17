with open(r'd:\Zeebull\dasboard\src\pages\Bookings.jsx', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

print("Calls to setIsBookingModalOpen:")
for idx, line in enumerate(lines):
    if 'setIsBookingModalOpen' in line:
        print(f"Line {idx+1}: {line.strip()}")
