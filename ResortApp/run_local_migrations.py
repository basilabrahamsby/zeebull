import os
import subprocess
from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv()

db_url = os.getenv("DATABASE_URL")
print("=== LOCAL DATABASE MIGRATION ===")
print("Loaded DATABASE_URL:", db_url)

if not db_url:
    print("ERROR: DATABASE_URL not found in .env!")
    exit(1)

# Run alembic upgrade head
print("Running 'alembic upgrade head'...")
# Run via python -m alembic to avoid path/activation issues
result = subprocess.run(
    ["venv\\Scripts\\python.exe", "-m", "alembic", "upgrade", "head"],
    capture_output=True,
    text=True
)

print("\n--- MIGRATION OUTPUT (STDOUT) ---")
print(result.stdout)

print("\n--- MIGRATION ERRORS (STDERR) ---")
print(result.stderr)

if result.returncode == 0:
    print("\nSUCCESS: Database migrations completed successfully!")
else:
    print(f"\nFAILURE: Migrations failed with exit code {result.returncode}")
