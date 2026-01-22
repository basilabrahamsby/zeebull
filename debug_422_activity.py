
import sys
import os
sys.path.append('/var/www/inventory/ResortApp')
from app.database import SessionLocal
from sqlalchemy import text
import json

def get_last_error():
    db = SessionLocal()
    try:
        # Get the most recent 422 error
        sql = text("""
            SELECT id, action, method, path, status_code, details, timestamp 
            FROM activity_logs 
            WHERE status_code = 422 
            ORDER BY timestamp DESC 
            LIMIT 1
        """)
        row = db.execute(sql).fetchone()
        
        if row:
            print(f"--- 422 ERROR DETAILS ---")
            print(f"ID: {row[0]}")
            print(f"Action: {row[1]}")
            print(f"Method: {row[2]}")
            print(f"Path: {row[3]}")
            print(f"Time: {row[6]}")
            print(f"Details: {row[5]}") # This might contain the validation error message if I captured only duration or more? 
            # My logging middleware captures "Duration: ...". 
            # Oh, the standard middleware I wrote ONLY captures duration in `details`.
            # Usefulness might be limited if I didn't capture the response body.
            # But the ActivityLoggingMiddleware I wrote earlier:
            #     details=f"Duration: {process_time:.4f}s"
            # It DOES NOT capture the response body. Darn.
            
            # However, standard FastAPI logging usually prints validation errors to stdout/stderr.
            # I might need to check system logs (journalctl) instead.
            
        else:
            print("No recent 422 errors found in activity_logs.")
            
    finally:
        db.close()

if __name__ == "__main__":
    get_last_error()
