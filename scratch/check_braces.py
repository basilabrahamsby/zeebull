
import os

file_path = r'd:\Zeebull\Mobile\employee\lib\presentation\screens\manager\manager_service_assignment_screen.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

stack = []
for i, line in enumerate(lines):
    for j, char in enumerate(line):
        if char == '{':
            stack.append((i+1, j+1))
        elif char == '}':
            if not stack:
                print(f"Extra closing brace at line {i+1}, col {j+1}")
            else:
                stack.pop()

if stack:
    for line_num, col_num in stack:
        print(f"Unclosed opening brace at line {line_num}, col {col_num}")
else:
    print("All braces are balanced.")
