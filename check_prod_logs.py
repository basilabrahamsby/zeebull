import os
import sys
import datetime
import pytz

# Add current dir to path
sys.path.append(os.getcwd())

try:
    from app.database import SessionLocal, engine
    from app.models.employee import WorkingLog
    
    print(f"Engine: {engine.url}")
    db = SessionLocal()
    
    today = datetime.date.today()
    logs = db.query(WorkingLog).filter(WorkingLog.date == today).all()
    
    if logs:
        for log in logs:
            print(f"PROD_LOG: ID={log.id} | Emp={log.employee_id} | In={log.check_in_time} | Out={log.check_out_time}")
    else:
        # Get last 5 overall if none today
        logs = db.query(WorkingLog).order_by(WorkingLog.id.desc()).limit(5).all()
        for log in logs:
            print(f"PROD_LOG_LAST: ID={log.id} | Date={log.date} | In={log.check_in_time}")

except Exception as e:
    print(f"ERROR: {e}")
