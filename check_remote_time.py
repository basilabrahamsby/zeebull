import sys
import os
import datetime
import pytz

cwd = os.getcwd()
sys.path.append(os.path.join(cwd, 'backend_manual'))

# Manually set the DB URL from server .env 
os.environ["DATABASE_URL"] = "postgresql://orchid_user:production@localhost/orchid_resort"

try:
    from app.database import SessionLocal, engine
    from app.models.employee import WorkingLog
    from sqlalchemy import text
    
    print(f"DB_URL: {engine.url}")
    
    db = SessionLocal()
    
    # Check connection
    try:
        db.execute(text("SELECT 1"))
        print("DB Connection Successful")
    except Exception as e:
        print(f"DB Connection Failed: {e}")
        sys.exit(1)

    # Get all logs for today
    today = datetime.date.today()
    print(f"Checking logs for date: {today}")
    
    logs = db.query(WorkingLog).filter(WorkingLog.date == today).all()
    
    if logs:
        for log in logs:
            print(f"LOG: ID={log.id} | Emp={log.employee_id} | In={log.check_in_time} | Out={log.check_out_time}")
    else:
        print("NO_LOGS_TODAY")
        
    ist = pytz.timezone('Asia/Kolkata')
    print(f"SERVER_IST: {datetime.datetime.now(ist)}")
    
except Exception as e:
    print(f"ERROR: {e}")
    import traceback
    traceback.print_exc()
