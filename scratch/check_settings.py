import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.settings import SystemSetting

db = SessionLocal()

print("--- Querying all System Settings starting with 'mobile_app_' ---")
settings = db.query(SystemSetting).filter(SystemSetting.key.like('mobile_app_%')).all()
for s in settings:
    print(f"Key: {s.key}, Value: {s.value}, Branch: {s.branch_id}")

db.close()
