from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.user import User
from app.models.employee import Employee
from datetime import date

def fix_admin_employee():
    db: Session = SessionLocal()
    try:
        user_id = 1
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            print("User 1 (Admin) not found!")
            return

        print(f"Found User 1: {user.email}")
        
        # Check if linked
        emp = db.query(Employee).filter(Employee.user_id == user_id).first()
        if emp:
            print(f"User 1 is already linked to Employee {emp.id} ({emp.name})")
        else:
            print("User 1 is NOT linked to an Employee. Creating one...")
            new_emp = Employee(
                name=user.name or "Admin User",
                role="Manager",
                salary=0.0,
                join_date=date.today(),
                user_id=user.id,
                paid_leave_balance=12,
                sick_leave_balance=12,
                image_url=None
            )
            db.add(new_emp)
            db.commit()
            db.refresh(new_emp)
            print(f"Created Employee record for Admin: ID={new_emp.id}, Name={new_emp.name}")

    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    fix_admin_employee()
