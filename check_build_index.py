import os

file_path = '/home/dayon/ResortwithGstinventry/dasboard/build/index.html'
if os.path.exists(file_path):
    content = open(file_path, 'r').read()
    print(f"File Size: {os.path.getsize(file_path)}")
    print(f"Contains 'root': {'root' in content}")
    print(f"Contains '</html>': {'</html>' in content}")
    # Print the last 100 chars carefully
    end_part = content[-100:]
    print(f"End of file (repr): {repr(end_part)}")
else:
    print("File not found.")
