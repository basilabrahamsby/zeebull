import sys
import os
import traceback

sys.path.append(os.getcwd())

print("Testing import of app.api.inventory...")
try:
    import app.api.inventory as inventory
    print("SUCCESS: Module app.api.inventory imported")
    print(f"Router found: {hasattr(inventory, 'router')}")
except Exception:
    print("FAILURE: Import failed")
    traceback.print_exc()
