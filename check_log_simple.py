
import sys
import os
sys.path.append('/var/www/inventory/ResortApp')
from app.database import SessionLocal, engine
from sqlalchemy import inspect, text

def check_log_capability():
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    
    if 'activity_logs' in tables:
        print("STATUS: TABLE_EXISTS")
        db = SessionLocal()
        try:
            # Check count
            cnt = db.execute(text("SELECT count(*) FROM activity_logs")).scalar()
            print(f"STATUS: ROW_COUNT={cnt}")
            
            # Check last log
            if cnt > 0:
                last = db.execute(text("SELECT timestamp, path, method, status_code FROM activity_logs ORDER BY timestamp DESC LIMIT 1")).fetchone()
                print(f"STATUS: LAST_LOG={last}")
            else:
                print("STATUS: NO_LOGS")
        except Exception as e:
            print(f"STATUS: QUERY_ERROR={e}")
        finally:
            db.close()
    else:
        print("STATUS: TABLE_MISSING")

if __name__ == "__main__":
    check_log_capability()
