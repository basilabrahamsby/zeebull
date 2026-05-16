
import sys
import os
sys.path.append(os.getcwd())

from main import app

print("Registered Routes:")
for route in app.routes:
    if hasattr(route, 'path'):
        print(f"{route.path} (Methods: {getattr(route, 'methods', 'N/A')})")
