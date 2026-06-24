import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import traceback

load_dotenv('D:/Zeebull/ResortApp/.env')
url = os.getenv("DATABASE_URL")
engine = create_engine(url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

db = SessionLocal()
try:
    from app.schemas.service import AssignedServiceUpdate
    from app.curd.service import update_assigned_service_status
    
    from app.models.service import AssignedService
    from app.models.employee_inventory import EmployeeInventoryAssignment
    
    assigned = db.query(AssignedService).filter(AssignedService.id == 15).first()
    assigned.status = "in_progress"
    
    emp_assign = db.query(EmployeeInventoryAssignment).filter(EmployeeInventoryAssignment.assigned_service_id == 15).first()
    emp_assign.status = "in_use"
    emp_assign.quantity_used = 0.0
    emp_assign.quantity_returned = 0.0
    emp_assign.is_returned = False
    db.commit()
    
    class FakeReturn:
        def __init__(self, assignment_id, quantity_returned, quantity_used):
            self.assignment_id = assignment_id
            self.quantity_returned = quantity_returned
            self.quantity_used = quantity_used
            self.quantity_damaged = 0.0
            self.inventory_item_id = None
            self.return_location_id = None
            
    class FakeUpdate:
        def __init__(self, status, returns):
            self.status = status
            self.inventory_returns = returns
            self.employee_id = None
            self.return_location_id = None
            self.billing_status = None
            self.payment_status = None
            self.completion_notes = None
            
    update_data = FakeUpdate("completed", [FakeReturn(emp_assign.id, 0.1, 0.1)])
    
    print("Calling update_assigned_service_status...")
    update_assigned_service_status(db, 15, update_data, updated_by=1)
    print("Done calling update_assigned_service_status.")
    
except Exception as e:
    traceback.print_exc()
finally:
    db.close()
