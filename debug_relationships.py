from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee, WorkingLog
from sqlalchemy import func

def debug_relationships():
    db: Session = SessionLocal()
    try:
        print("\n--- USER <-> EMPLOYEE MAPPING ---")
        # specific join to see connected users
        results = db.query(User.id, User.email, Employee.id, Employee.name).outerjoin(Employee, User.id == Employee.user_id).all()
        for u_id, u_email, e_id, e_name in results:
            status = f"LINKED (Emp ID: {e_id})" if e_id else "NO EMPLOYEE RECORD"
            print(f"User [{u_id}] {u_email} -> {status} - Name: {e_name}")

        print("\n--- WORKING LOGS SUMMARY ---")
        log_counts = db.query(WorkingLog.employee_id, func.count(WorkingLog.id)).group_by(WorkingLog.employee_id).all()
        for emp_id, count in log_counts:
            print(f"Employee ID: {emp_id} has {count} logs")

    finally:
        db.close()

if __name__ == "__main__":
    debug_relationships()
