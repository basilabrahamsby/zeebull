import os
import sys

# Add project root to path
sys.path.append(os.getcwd())

from app.database import SessionLocal
from app.models.settings import SystemSetting
from app.utils.aiosell_config import is_aiosell_active

db = SessionLocal()

print("--- CHANNEL MANAGER STATUS CHECK ---")

# 1. Check Database
setting = db.query(SystemSetting).filter(SystemSetting.key == 'aiosell_active').first()
if setting:
    print(f"Database Setting ('aiosell_active'): {setting.value} (Updated: {setting.updated_at})")
else:
    print("Database Setting ('aiosell_active'): NOT FOUND (Using fallback)")

# 2. Check Environment Variable
env_val = os.getenv("AIOSELL_ACTIVE", "false")
print(f"Environment Variable (AIOSELL_ACTIVE): {env_val}")

# 3. Final Evaluated Status
status = is_aiosell_active(db)
print(f"\nFINAL EVALUATED STATUS: {'ACTIVE' if status else 'DISABLED'}")

db.close()
