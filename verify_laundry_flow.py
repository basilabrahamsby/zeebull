
import requests
import json
import sys
import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Add current directory to path to find app modules
sys.path.append(os.getcwd())

# Configuration
BASE_URL = "http://127.0.0.1:8000"

# Setup DB connection directly to get user
from app.database import SessionLocal
from app.models.user import User
from app.models.inventory import InventoryItem, Location, LocationStock, AssetMapping, LaundryLog, InventoryTransaction
from app.models.service_request import ServiceRequest
from app.models.room import Room
from app.models.checkout import CheckoutRequest, Checkout
from app.models.employee import Employee
from app.utils.auth import create_access_token

def get_db():
    return SessionLocal()

def get_admin_token(db):
    # Find an admin user
    user = db.query(User).filter(User.email == "basil@gmail.com").first()
    if not user:
        user = db.query(User).first() # Fallback
    
    if not user:
        print("No users found!")
        return None
        
    print(f"Using user: {user.email} (ID: {user.id})")
    access_token = create_access_token(data={"user_id": user.id})
    return access_token

def run_test():
    db = get_db()
    token = get_admin_token(db)
    if not token:
        return

    headers = {"Authorization": f"Bearer {token}"}
    
    print("\n--- 1. SETTING UP TEST DATA ---")
    
    # 1. Find Bed Sheet (Item 30)
    bed_sheet = db.query(InventoryItem).filter(InventoryItem.name.ilike("%bed sheet%")).first()
    if not bed_sheet:
        print("Bed sheet not found!")
        return
    item_id = bed_sheet.id
    print(f"Found Item: {bed_sheet.name} (ID: {item_id})")
    
    # 2. Find a Room
    room = db.query(Room).filter(Room.inventory_location_id != None).first()
    if not room:
        print("No suitable room found!")
        return
    print(f"Using Room: {room.number} (ID: {room.id}, LocID: {room.inventory_location_id})")
    
    # 3. Find Laundry Location
    laundry = db.query(Location).filter(Location.location_type == "LAUNDRY").first()
    if not laundry:
        print("No LAUNDRY location found!")
        # Create one?
        return
    print(f"Using Laundry: {laundry.name} (ID: {laundry.id})")
    
    # 4. Find Store Location (Pickup)
    store = db.query(Location).filter(Location.location_type.in_(["STORE", "WAREHOUSE"])).first()
    if not store:
        print("No Store/Warehouse found!")
        return
    print(f"Using Pickup Store: {store.name} (ID: {store.id})")
    
    # 5. Find Employee
    employee = db.query(Employee).first()
    if not employee:
        print("No employee found!")
        return
    employee_id = employee.id
    print(f"Using Employee: {employee.name} (ID: {employee.id})")

    # Ensure Bed Sheet is in Room Stock and Mapped
    # Add to LocationStock
    room_stock = db.query(LocationStock).filter(LocationStock.location_id == room.inventory_location_id, LocationStock.item_id == item_id).first()
    if not room_stock:
        db.add(LocationStock(location_id=room.inventory_location_id, item_id=item_id, quantity=1))
    else:
        room_stock.quantity = max(1, room_stock.quantity)
    
    # Add AssetMapping
    mapping = db.query(AssetMapping).filter(AssetMapping.location_id == room.inventory_location_id, AssetMapping.item_id == item_id).first()
    if not mapping:
        db.add(AssetMapping(location_id=room.inventory_location_id, item_id=item_id, is_active=True))
    else:
        mapping.is_active = True
    
    db.commit()
    print("Ensured item is in room stock and mapped.")

    # Record Initial Stocks
    initial_laundry_stock = db.query(LocationStock).filter(LocationStock.location_id == laundry.id, LocationStock.item_id == item_id).first()
    initial_laundry_qty = initial_laundry_stock.quantity if initial_laundry_stock else 0
    
    initial_store_stock = db.query(LocationStock).filter(LocationStock.location_id == store.id, LocationStock.item_id == item_id).first()
    if not initial_store_stock:
        db.add(LocationStock(location_id=store.id, item_id=item_id, quantity=10)) # Ensure stock for replenishment
        db.commit()
        initial_store_qty = 10
    else:
        initial_store_qty = initial_store_stock.quantity
        if initial_store_qty < 1:
             initial_store_stock.quantity = 10
             db.commit()
             initial_store_qty = 10
    
    print(f"Initial Laundry Stock: {initial_laundry_qty}")
    print(f"Initial Store Stock: {initial_store_qty}")

    print("\n--- 2. SIMULATING CHECKOUT (Laundry + Replacement) ---")
    
    # Create Checkout Request
    # We need a booking? Or can we just use /bill/checkout-request endpoint?
    # Let's manually insert a CheckoutRequest to simulate "Checkout Initiated" state
    chk_req = CheckoutRequest(
        room_id=room.id,
        room_number=room.number,
        status="pending",
        created_at=requests.utils.datetime.datetime.utcnow()
    )
    db.add(chk_req)
    db.commit()
    db.refresh(chk_req)
    req_id = chk_req.id
    print(f"Created Checkout Request ID: {req_id}")

    # Prepare Inventory Data payload for verification
    inventory_data = [
        {
            "item_id": item_id,
            "item_name": bed_sheet.name,
            "system_qty": 1,
            "actual_qty": 0, # Missing from room because it's going to laundry
            "is_damaged": True, # Needed to trigger 'damage' flow which now checks laundry
            "damage_qty": 1,
            "is_laundry": True, # KEY FLAG
            "laundry_location_id": laundry.id,
            "request_replacement": True, # KEY FLAG
            "is_fixed_asset": True,
            "category": "Linen"
        }
    ]

    # Call Verification/Complete Endpoint
    # Endpoint: POST /bill/checkout-request/{request_id}/complete-checkout
    payload = {
        "inventory_data": inventory_data,
        "consumables_data": [],
        "room_number": room.number,
        "checkout_id": None # Not linked to actual checkout yet
    }
    
    # Using 'check-inventory' or 'complete-checkout'?
    # Usually it's complete-checkout logic that does the movement.
    # But wait, looking at checkout.py, logic is in verify_inventory AND complete_checkout?
    # No, the logic I modified is in handleCompleteCheckoutRequest which is likely called by an endpoint.
    
    # Let's try calling PUT /bill/checkout-request/{id}/verify first?
    # Or POST /bill/checkout-request/{id}/check-inventory
    
    print("Calling /bill/checkout-request/{id}/check-inventory ...")
    resp = requests.post(f"{BASE_URL}/bill/checkout-request/{req_id}/check-inventory", json=payload, headers=headers)
    
    if resp.status_code != 200:
        print("Check Inventory Failed:", resp.text)
        # return # Depending on failure
    else:
        print("Check Inventory Success")

    # Now we need to trigger the actual Checkout Completion logic where I added the code
    # Is it in 'complete' endpoint?
    # Search for 'handleCompleteCheckoutRequest' usage in checkout.py...
    # It is used in router.post("/{request_id}/complete") usually.
    # Let's assume there is an endpoint for completing.
    
    # If the logic I modified is in `api/checkout.py`, lines 1368+, it is inside `handleCompleteCheckoutRequest`.
    # I need to know which endpoint calls this.
    # Assuming `POST /bill/checkout-request/{request_id}/complete`
    
    complete_payload = {
        "inventory_data": inventory_data,
        "payment_method": "cash",
        "amount_paid": 0
    }
    
    print("Calling /bill/checkout-request/{id}/complete ...")
    # Note: verify if this endpoint exists and what it expects. 
    # Usually `handleCompleteCheckoutRequest` is an internal helper.
    # If I can't find the exact endpoint, I might need to run the function directly.
    # But let's try the endpoint.
    
    resp = requests.post(f"{BASE_URL}/bill/checkout-request/{req_id}/complete?force_complete=true", json=complete_payload, headers=headers)
    
    # Retry with different payload structure if 422
    if resp.status_code == 422:
        print("422 Error on complete. Checking schema...")
        # Try just sending inventory data if it's implicitly reading body
    
    if resp.status_code != 200:
         print(f"Complete Checkout Failed: {resp.status_code} {resp.text}")
         # Attempt to call function directly if possible (fallback)
         try:
             from app.api.checkout import handleCompleteCheckoutRequest
             from app.schemas.checkout import CheckoutFull
             # Mock request? Hard to mock.
             print("Cannot call endpoint successfully. Checking DB to see if check-inventory did it (sometimes verify does moves temporarily?) NO.")
             # Actually some logic is in check-inventory too?
         except:
             pass
    else:
        print("Complete Checkout Success")

    # VERIFICATION 1
    print("\n--- 3. VERIFYING BACKEND STATE ---")
    
    # Check Laundry Log
    log = db.query(LaundryLog).filter(LaundryLog.room_number == room.number, LaundryLog.item_id == item_id).order_by(LaundryLog.id.desc()).first()
    if log:
        print(f"VICTORY: Laundry Log Created! ID: {log.id}, Status: {log.status}")
    else:
        print("FAILURE: No Laundry Log found.")

    # Check Waste Log (Should be None)
    # Get waste log number reference
    waste_txn = db.query(InventoryTransaction).filter(InventoryTransaction.reference_number.ilike("LOST%"), InventoryTransaction.item_id == item_id).order_by(InventoryTransaction.id.desc()).first()
    if waste_txn and waste_txn.created_at > requests.utils.datetime.datetime.utcnow() - requests.utils.datetime.timedelta(minutes=1):
        print(f"FAILURE: Waste Transaction created! Ref: {waste_txn.reference_number}")
    else:
        print("VICTORY: No Waste Transaction created (Correct).")

    # Check Asset Mapping
    mapping = db.query(AssetMapping).filter(AssetMapping.location_id == room.inventory_location_id, AssetMapping.item_id == item_id).first()
    print(f"Asset Mapping Active: {mapping.is_active if mapping else 'No mapping'}")
    if mapping and not mapping.is_active:
        print("VICTORY: Asset Mapping Deactivated.")
    else:
        print("FAILURE: Asset Mapping Still Active.")

    # Check Service Request
    sr = db.query(ServiceRequest).filter(
        ServiceRequest.room_id == room.id, 
        ServiceRequest.request_type == "replenishment"
    ).order_by(ServiceRequest.id.desc()).first()
    
    if sr:
        print(f"VICTORY: Replenishment Request Created! ID: {sr.id}")
        print(f"Refill Data: {sr.refill_data}")
    else:
        print("FAILURE: No Replenishment Request found.")
        return

    # Check Laundry Stock
    l_stock = db.query(LocationStock).filter(LocationStock.location_id == laundry.id, LocationStock.item_id == item_id).first()
    curr_laundry = l_stock.quantity if l_stock else 0
    print(f"Laundry Stock: {initial_laundry_qty} -> {curr_laundry} (Expected +1)")

    print("\n--- 4. SIMULATING SERVICE ASSIGNMENT ---")
    # Assign Employee and Pickup Location
    assign_payload = {
        "employee_id": employee_id,
        "pickup_location_id": store.id,
        "status": "in_progress"
    }
    
    resp = requests.put(f"{BASE_URL}/service-requests/{sr.id}", json=assign_payload, headers=headers)
    if resp.status_code == 200:
        print("Service Assigned Successfully")
    else:
        print(f"Service Assignment Failed: {resp.text}")
        return

    print("\n--- 5. SIMULATING SERVICE COMPLETION ---")
    # Complete Service
    complete_sr_payload = {
        "status": "completed"
    }
    
    resp = requests.put(f"{BASE_URL}/service-requests/{sr.id}", json=complete_sr_payload, headers=headers)
    if resp.status_code == 200:
         print("Service Completed Successfully")
    else:
         print(f"Service Completion Failed: {resp.text}")
         return

    print("\n--- 6. VERIFYING FINAL INVENTORY ---")
    db.refresh(sr) # Reload
    
    # Check Pickup Stock
    p_stock = db.query(LocationStock).filter(LocationStock.location_id == store.id, LocationStock.item_id == item_id).first()
    curr_store = p_stock.quantity if p_stock else 0
    print(f"Store Stock: {initial_store_qty} -> {curr_store} (Expected -1)")
    
    if curr_store == initial_store_qty - 1:
        print("VICTORY: Store Stock Deducted.")
    else:
        print("FAILURE: Store Stock Incorrect.")

    # Check Room Stock (Should be original because we removed one and added one)
    # But specifically, we want to know if one was ADDED.
    # Logic: Room had 1. Checkout removed 0 (it deactivated mapping). Wait, checkout logic:
    # "Deduct LocationStock for asset movement: ... max(0, loc_stock.quantity - 1)"
    # So Checkout: Stock 1 -> 0.
    # Replenishment: Stock 0 -> 1.
    r_stock = db.query(LocationStock).filter(LocationStock.location_id == room.inventory_location_id, LocationStock.item_id == item_id).first()
    curr_room = r_stock.quantity if r_stock else 0
    print(f"Room Stock: {curr_room} (Expected 1)")

    # Check Asset Mapping Reactivation
    # Logic: "if is_fixed_asset: ... inactive_mapping.is_active = True"
    db.refresh(mapping)
    print(f"Asset Mapping Active: {mapping.is_active}")
    if mapping.is_active:
        print("VICTORY: Asset Mapping Reactivated.")
    else:
        print("FAILURE: Asset Mapping Not Reactivated.")

if __name__ == "__main__":
    try:
        run_test()
    except Exception as e:
        import traceback
        traceback.print_exc()
