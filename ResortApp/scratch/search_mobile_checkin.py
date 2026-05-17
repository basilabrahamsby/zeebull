with open(r'd:\Zeebull\Mobile\employee\lib\presentation\screens\manager\manager_checkin_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print("Searching for check-in endpoint calls in manager_checkin_screen.dart:")
for i, line in enumerate(lines):
    if 'check-in' in line.lower() or 'checkin' in line.lower() or 'package' in line.lower():
        print(f"Line {i+1}: {line.strip()}")
