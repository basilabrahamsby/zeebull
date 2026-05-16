
import re

file_path = r'd:\Zeebull\Mobile\employee\lib\presentation\screens\manager\manager_service_assignment_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

class_scope = None
brace_level = 0
for i, line in enumerate(lines):
    # Find class definitions
    match = re.search(r'class\s+(\w+)', line)
    if match:
        class_name = match.group(1)
        # print(f"Found class {class_name} at line {i+1}")
        
    for char in line:
        if char == '{':
            brace_level += 1
        elif char == '}':
            brace_level -= 1
            if brace_level < 0:
                print(f"Brace underflow at line {i+1}")
                brace_level = 0
    
    # Check if we are at line 1693
    if i + 1 == 1693:
        print(f"Brace level at line 1693: {brace_level}")

print(f"Final brace level: {brace_level}")
