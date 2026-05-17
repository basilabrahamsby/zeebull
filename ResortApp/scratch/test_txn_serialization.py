from app.database import SessionLocal
from app.models.inventory import InventoryTransaction
from app.schemas.inventory import InventoryTransactionOut

db = SessionLocal()
try:
    t = db.query(InventoryTransaction).filter(InventoryTransaction.id == 256).first()
    if t:
        print(f"Transaction ID 256:")
        print(f"Item ID: {t.item_id}, Item Name: {t.item.name}")
        print(f"Transaction Type: {t.transaction_type}")
        print(f"Quantity: {t.quantity}")
        print(f"Reference Number: {t.reference_number}")
        print(f"Notes: {t.notes}")
        print(f"Source Location ID: {t.source_location_id}, Name: {t.source_location.name if t.source_location else 'None'}")
        print(f"Destination Location ID: {t.destination_location_id}, Name: {t.destination_location.name if t.destination_location else 'None'}")
        
        # Test serialization
        # Let's mock the mapping of model fields
        t_out = {
            "id": t.id,
            "item_id": t.item_id,
            "item_name": t.item.name,
            "transaction_type": t.transaction_type,
            "quantity": t.quantity,
            "unit_price": t.unit_price,
            "total_amount": t.total_amount,
            "reference_number": t.reference_number,
            "purchase_master_id": t.purchase_master_id,
            "notes": t.notes,
            "created_by": t.created_by,
            "created_by_name": t.user.name if t.user else "System",
            "source_location_name": t.source_location.name if t.source_location else None,
            "destination_location_name": t.destination_location.name if t.destination_location else None,
            "created_at": t.created_at
        }
        out_obj = InventoryTransactionOut(**t_out)
        print("Serialization success!")
        print(out_obj.model_dump())
    else:
        print("Transaction ID 256 not found!")
finally:
    db.close()
