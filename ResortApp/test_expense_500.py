import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import date

# Add the app directory to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), ".")))

from app.database import SessionLocal, engine
from app.curd import expenses as expense_crud
from app.schemas.expenses import ExpenseCreate
from app.models.user import User
from app.models.employee import Employee
from app.utils.accounting_helpers import create_expense_journal_entry

def test_create_expense():
    db = SessionLocal()
    try:
        # Data from HAR log
        employee_id = 5
        category = "petrol"
        amount = 2000.0
        expense_date = date(2026, 5, 15)
        description = ""
        department = "Restaurant"
        payment_mode = "Cash"
        branch_id = 1
        
        print(f"Attempting to create expense for employee_id={employee_id}, branch_id={branch_id}")
        
        # Verify employee exists
        employee = db.query(Employee).filter(Employee.id == employee_id, Employee.branch_id == branch_id).first()
        if not employee:
            print(f"Warning: Employee with ID {employee_id} not found in branch {branch_id}")
        else:
            print(f"Found employee: {employee.name}")

        # 1. Create Expense in DB
        expense_data = ExpenseCreate(
            category=category,
            amount=amount,
            date=expense_date,
            description=description,
            employee_id=employee_id,
            department=department,
            payment_mode=payment_mode
        )
        
        print("Calling expense_crud.create_expense...")
        created = expense_crud.create_expense(db, data=expense_data, branch_id=branch_id, image_path=None)
        print(f"Expense created successfully in DB with ID: {created.id}")

        # 2. Create Journal Entry
        print("Calling create_expense_journal_entry...")
        # We need a user ID for created_by
        user = db.query(User).first()
        if not user:
            print("Error: No user found in database to use as created_by")
            return
            
        create_expense_journal_entry(
            db=db,
            expense_id=created.id,
            amount=float(amount),
            category=category,
            description=description or "",
            payment_mode=payment_mode,
            created_by=user.id,
            branch_id=branch_id
        )
        print("Journal entry created successfully")
        
        # 3. Final response logic
        print("Testing response logic...")
        employee = db.query(Employee).filter(Employee.id == employee_id, Employee.branch_id == branch_id).first()
        response = {
            **created.__dict__,
            "employee_name": employee.name if employee else "N/A"
        }
        print("Response logic completed")
        print(f"Result: {response}")

    except Exception as e:
        print(f"ERROR CAUGHT: {e}")
        import traceback
        traceback.print_exc()
    finally:
        db.close()

if __name__ == "__main__":
    test_create_expense()
