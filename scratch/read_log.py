import os

log_path = r"d:\Zeebull\ResortApp\backend.log"

encodings = ['utf-16', 'utf-16-le', 'utf-8', 'latin-1']
for enc in encodings:
    try:
        with open(log_path, 'r', encoding=enc) as f:
            content = f.read()
            if content:
                print(f"--- SUCCESS WITH ENCODING: {enc} ---")
                lines = content.splitlines()
                for line in lines[-100:]:
                    print(line)
                break
    except Exception as e:
        print(f"Failed with {enc}: {e}")
