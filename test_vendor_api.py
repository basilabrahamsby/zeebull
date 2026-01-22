import sys
import os
sys.path.append(os.getcwd())
from app.api.dashboard import get_vendor_stats
from app.database import SessionLocal
from app.models.user import User
db = SessionLocal()
user = db.query(User).first()
try:
    stats = get_vendor_stats(db, user)
    print('--- Stats Result ---')
    print(stats)
except Exception as e:
    import traceback; traceback.print_exc()
