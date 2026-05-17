with open(r'd:\Zeebull\dasboard\src\pages\Bookings.jsx', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

print("Searching for email inputs in BookingFormModal:")
for idx in range(3239, 3600):
    if idx < len(lines):
        line = lines[idx]
        if 'email' in line.lower() or 'guest_email' in line.lower() or 'guestemail' in line.lower() or 'mail' in line.lower():
            print(f"Line {idx+1}: {line.strip()}")
