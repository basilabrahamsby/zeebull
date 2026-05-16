from app.database import SessionLocal
from sqlalchemy import text

def clear_remaining_transactions():
    db = SessionLocal()
    try:
        tables = [
            "day_audits",
            "salary_payments",
            "laundry_logs",
            "activity_logs",
            "guest_suggestions",
            "vouchers",
            "reviews",
            "working_logs",
            "attendances",
            "leaves"
        ]
        
        print("Clearing remaining transactional tables...")
        for table in tables:
            try:
                db.execute(text(f"DELETE FROM {table}"))
                print(f"  OK: {table} cleared")
            except Exception as e:
                print(f"  Wait: Could not clear {table}: {e}")
        
        db.commit()
        print("Cleanup complete.")
    except Exception as e:
        db.rollback()
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    clear_remaining_transactions()
