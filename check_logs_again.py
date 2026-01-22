
import sys
import os
sys.path.append('/var/www/inventory/ResortApp')
from app.database import SessionLocal
from sqlalchemy import text

def check_logs():
    db = SessionLocal()
    try:
        # Get last 5 logs
        sql = text("SELECT id, action, status_code, timestamp, details FROM activity_logs ORDER BY id DESC LIMIT 5")
        rows = db.execute(sql).fetchall()
        print("--- Recent Activity Logs ---")
        for row in rows:
            print(f"ID: {row[0]}, Action: {row[1]}, Status: {row[2]}, Time: {row[3]}")
    finally:
        db.close()

if __name__ == "__main__":
    check_logs()
