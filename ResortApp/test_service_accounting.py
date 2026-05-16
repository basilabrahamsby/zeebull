from app.database import SessionLocal
from app.models.service import Service, AssignedService, ServiceStatus
from app.models.room import Room
from app.models.employee import Employee
from app.curd.service import update_assigned_service_status
from app.schemas.service import AssignedServiceUpdate
from app.models.account import JournalEntry
import uuid

def test_service_payment_accounting():
    print("Testing Service Payment Accounting Sync...")
    db = SessionLocal()
    try:
        # 1. Find a service, room, and employee
        service = db.query(Service).first()
        room = db.query(Room).first()
        employee = db.query(Employee).first()
        
        if not all([service, room, employee]):
            print("FAILED: Missing required test data (Service/Room/Employee)")
            return

        print(f"Using Service: {service.name} (Charges: {service.charges})")
        print(f"Using Room: {room.number}")
        
        # 2. Create an AssignedService
        asvc = AssignedService(
            service_id=service.id,
            room_id=room.id,
            employee_id=employee.id,
            branch_id=service.branch_id,
            billing_status="unbilled",
            status=ServiceStatus.pending
        )
        db.add(asvc)
        db.commit()
        db.refresh(asvc)
        print(f"Assigned Service Created: ID {asvc.id}")

        # 3. Mark as Paid and Completed
        update_data = AssignedServiceUpdate(
            status="completed",
            billing_status="paid",
            payment_mode="cash"
        )
        
        updated_asvc = update_assigned_service_status(db, asvc.id, update_data)
        
        if not updated_asvc:
            print("FAILED: Service status update failed")
            return

        print(f"Service marked as PAID and COMPLETED.")

        # 4. Verify Journal Entry
        je = db.query(JournalEntry).filter(
            JournalEntry.reference_type == "service_payment",
            JournalEntry.reference_id == asvc.id
        ).first()
        
        if je:
            print(f"SUCCESS: Journal Entry Created: {je.entry_number}")
            print(f"Description: {je.description}")
            for line in je.lines:
                ledger_name = line.debit_ledger.name if line.debit_ledger else line.credit_ledger.name
                type = "DEBIT" if line.debit_ledger_id else "CREDIT"
                print(f"  - {type} {ledger_name}: {line.amount}")
        else:
            print("FAILED: No Journal Entry found for the service payment.")
            
    finally:
        db.close()

if __name__ == "__main__":
    test_service_payment_accounting()
