from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee

def debug_emp1():
    db: Session = SessionLocal()
    try:
        emp1 = db.query(Employee).filter(Employee.id == 1).first()
        if emp1:
            print(f"Employee 1: Name={emp1.name}, User_ID={emp1.user_id}")
            if emp1.user_id:
                user = db.query(User).filter(User.id == emp1.user_id).first()
                if user:
                    print(f"  -> Linked to User: ID={user.id}, Email={user.email}")
                else:
                    print("  -> Linked to User ID that does not exist!")
            else:
                print("  -> Not linked to any User!")
        else:
            print("Employee 1 does not exist.")
            
        # Also check User 1
        user1 = db.query(User).filter(User.id == 1).first()
        if user1:
            print(f"User 1: Email={user1.email}")
            # check reverse
            emp_reverse = db.query(Employee).filter(Employee.user_id == 1).first()
            if emp_reverse:
                print(f"  -> Linked to Employee: ID={emp_reverse.id}, Name={emp_reverse.name}")
            else:
                print("  -> Not linked to any Employee!")
                
    finally:
        db.close()

if __name__ == "__main__":
    debug_emp1()
