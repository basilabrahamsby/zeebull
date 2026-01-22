
import os
MAIN_PY = "/var/www/inventory/ResortApp/main.py"

def patch_main():
    if not os.path.exists(MAIN_PY):
        print(f"Error: {MAIN_PY} not found.")
        return

    with open(MAIN_PY, "r") as f:
        lines = f.readlines()

    # Check if already patched
    if any("ActivityLoggingMiddleware" in line for line in lines):
        print("main.py already contains ActivityLoggingMiddleware. Skipping.")
        return

    new_lines = []
    imported = False
    added = False

    for line in lines:
        new_lines.append(line)
        
        # Add import near other middleware imports
        if "from starlette.middleware.base import BaseHTTPMiddleware" in line and not imported:
            new_lines.append("from app.middleware.activity_logging import ActivityLoggingMiddleware\n")
            imported = True
        
        # Add middleware registration after GZip
        if "app.add_middleware(GZipMiddleware" in line and not added:
            new_lines.append("\n# Activity Logging Middleware\n")
            new_lines.append("app.add_middleware(ActivityLoggingMiddleware)\n")
            added = True

    # Safety check
    if not imported or not added:
        print("Could not find insertion points. Dumping debug info...")
        # Fallback: append to end? No, app is defined earlier.
        # Fallback: Insert import at top and middleware after app creation.
    else:
        with open(MAIN_PY, "w") as f:
            f.writelines(new_lines)
        print("Successfully patched main.py")

if __name__ == "__main__":
    patch_main()
