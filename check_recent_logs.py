
import sys
import os

# Add the app directory to sys.path
sys.path.append('/var/www/inventory/ResortApp')

from app.database import SessionLocal
from sqlalchemy import text

def check_logs():
    db = SessionLocal()
    try:
        # Query last 5 logs
        sql = text("SELECT id, action, method, path, status_code, timestamp FROM activity_logs ORDER BY timestamp DESC LIMIT 5")
        result = db.execute(sql)
        
        print("\n--- Recent Activity Logs ---")
        rows = result.fetchall()
        if not rows:
            print("No logs found.")
        else:
            for row in rows:
                print(f"ID: {row[0]}, Action: {row[1]}, Method: {row[2]}, Path: {row[3]}, Status: {row[4]}, Time: {row[5]}")
                
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_logs()
