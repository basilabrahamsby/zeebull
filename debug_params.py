from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee
from sqlalchemy import func

def debug_relationships():
    db: Session = SessionLocal()
    try:
        print("\n--- LINKED USERS ---")
        results = db.query(User.id, User.email, Employee.id, Employee.name).join(Employee, User.id == Employee.user_id).all()
        for u_id, u_email, e_id, e_name in results:
            print(f"User [{u_id}] {u_email} <-> Emp [{e_id}] {e_name}")

    finally:
        db.close()

if __name__ == "__main__":
    debug_relationships()
