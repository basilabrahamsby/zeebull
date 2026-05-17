with open(r'd:\Zeebull\dasboard\src\pages\Bookings.jsx', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

def print_function(name):
    for idx, line in enumerate(lines):
        if name in line and ('const ' in line or 'function ' in line or 'async' in line):
            print(f"\n--- {name} starting at Line {idx+1} ---")
            for j in range(60):
                if idx + j < len(lines):
                    print(f"Line {idx+j+1}: {lines[idx+j].rstrip()}")
            break

print_function("handleSubmit")
print_function("handlePackageBookingSubmit")
