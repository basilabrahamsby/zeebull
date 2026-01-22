import os

log_path = '/home/dayon/ResortwithGstinventry/dasboard/build_log.txt'
if os.path.exists(log_path):
    with open(log_path, 'r') as f:
        content = f.read()
    print("--- BUILD LOG START ---")
    print(content)
    print("--- BUILD LOG END ---")
else:
    print("Log not found.")
