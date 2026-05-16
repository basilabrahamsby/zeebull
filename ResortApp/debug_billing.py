
from app.utils.auth import get_db
from app.api.checkout import _calculate_bill_for_single_room
from app.models.booking import Booking
from app.models.room import Room
from app.models.checkout import CheckoutRequest
from app.schemas.checkout import BillBreakdown
from datetime import datetime

db = next(get_db())
room_number = "502"
branch_id = 1 # Assuming branch 1

print(f"DEBUG: Room {room_number}, Branch {branch_id}")

# Calculate bill
bill_data = _calculate_bill_for_single_room(db, room_number, branch_id)

print("\n--- BILL DATA ---")
print(f"Guest: {bill_data['booking'].guest_name}")
print(f"Stay Nights: {bill_data['stay_nights']}")

charges = bill_data['charges']
print("\n--- CHARGES ---")
print(f"Food Charges: {charges.food_charges}")
print(f"Food Items: {charges.food_items}")
print(f"Service Charges: {charges.service_charges}")
print(f"Service Items: {charges.service_items}")
print(f"Inventory Charges: {charges.inventory_charges}")
print(f"Inventory Usage: {charges.inventory_usage}")
print(f"Consumables Charges: {charges.consumables_charges}")
print(f"Consumables Items: {charges.consumables_items}")
print(f"Asset Damage Charges: {charges.asset_damage_charges}")
print(f"Asset Damages: {charges.asset_damages}")
print(f"Total Due: {charges.total_due}")
