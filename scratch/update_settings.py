import os
import sys

sys.path.append('/var/www/zeebull/ResortApp')
os.chdir('/var/www/zeebull/ResortApp')

from app.database import SessionLocal
from app.models.settings import SystemSetting

db = SessionLocal()

print("--- Updating mobile_app_min_version to 1.2.3 ---")
setting = db.query(SystemSetting).filter(SystemSetting.key == 'mobile_app_min_version', SystemSetting.branch_id == None).first()
if setting:
    setting.value = '1.2.3'
    db.commit()
    print("Successfully updated mobile_app_min_version to 1.2.3")
else:
    print("Setting mobile_app_min_version not found in DB")

db.close()
