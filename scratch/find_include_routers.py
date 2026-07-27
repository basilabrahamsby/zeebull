import re
import os

root_dir = r"c:\releasing\New Orchid\ResortApp\app"

print("Searching for include_router calls in app/...")
for root, dirs, files in os.walk(root_dir):
    for file in files:
        if file.endswith(".py"):
            path = os.path.join(root, file)
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
            if "include_router" in content:
                print(f"File: {path}")
                for line in content.splitlines():
                    if "include_router" in line:
                        print(f"  {line.strip()}")
