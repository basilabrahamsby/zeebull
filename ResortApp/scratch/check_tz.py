import os
import sys
sys.path.append(os.getcwd())

from app.database import SessionLocal
from datetime import datetime, timezone, timedelta
from sqlalchemy import text

db = SessionLocal()
try:
    # Get PostgreSQL timezone
    res = db.execute(text("SHOW TIMEZONE")).fetchone()
    print(f"PostgreSQL timezone: {res[0] if res else 'Unknown'}")
    
    # Check naive vs aware datetime behavior
    res = db.execute(text("SELECT NOW()")).fetchone()
    print(f"SELECT NOW(): {res[0]} (Type: {type(res[0])})")
    
    # Check current system timezone offset
    print(f"Python datetime.now(): {datetime.now()}")
    print(f"Python datetime.now(timezone.utc): {datetime.now(timezone.utc)}")

except Exception as e:
    print(f"Error: {e}")
finally:
    db.close()
