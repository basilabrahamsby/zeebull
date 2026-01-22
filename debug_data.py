from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee, WorkingLog

def debug_data():
    db: Session = SessionLocal()
    try:
        print("--- USERS ---")
        users = db.query(User).all()
        for u in users:
            print(f"ID: {u.id}, Name: {u.name}, Email: {u.email}, Role: {u.role_id}")

        print("\n--- EMPLOYEES ---")
        employees = db.query(Employee).all()
        for e in employees:
            print(f"ID: {e.id}, Name: {e.name}, User ID: {e.user_id}")

        print("\n--- WORKING LOGS ---")
        logs = db.query(WorkingLog).all()
        for l in logs:
            print(f"ID: {l.id}, Emp ID: {l.employee_id}, Date: {l.date}, In: {l.check_in_time}, Out: {l.check_out_time}")

    finally:
        db.close()

if __name__ == "__main__":
    debug_data()
