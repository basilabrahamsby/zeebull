import subprocess
import os
import sys

scripts = [
    "seed_initial_data.py",
    "seed_inventory_items.py",
    "seed_diverse_rooms.py",
    "seed_accounting_data.py",
    "seed_assets_and_sync.py"
]

venv_python = os.path.abspath("venv/Scripts/python.exe")
if not os.path.exists(venv_python):
    venv_python = "python"

for script in scripts:
    print(f"Running {script}...")
    try:
        res = subprocess.run([venv_python, script], capture_output=True, text=True, cwd=os.path.abspath("."))
        print(res.stdout)
        if res.stderr:
            print(f"Errors in {script}:\n{res.stderr}")
    except Exception as e:
        print(f"Failed to run {script}: {e}")
