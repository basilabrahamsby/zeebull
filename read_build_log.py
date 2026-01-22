import os

log_path = '/home/dayon/ResortwithGstinventry/dasboard/build_log.txt'
if os.path.exists(log_path):
    with open(log_path, 'r') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if 'Module not found' in line:
                print("FOUND ERROR:")
                for j in range(max(0, i-2), min(len(lines), i+10)):
                    print(lines[j].strip())
else:
    print("Log not found.")
