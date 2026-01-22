import requests
import json

base_url = "http://136.113.93.47:8011/api"

print("=== Checking Rooms API ===")
try:
    response = requests.get(f"{base_url}/rooms")
    if response.status_code == 200:
        rooms = response.json()
        for room in rooms[:5]:  # First 5 rooms
            print(f"Room {room.get('number')}: status='{room.get('status')}', housekeeping='{room.get('housekeeping_status')}'")
except Exception as e:
    print(f"Error: {e}")

print("\n=== Checking Purchases API ===")
try:
    response = requests.get(f"{base_url}/inventory/purchases", params={"status": "received"})
    if response.status_code == 200:
        purchases = response.json()
        print(f"Total received purchases: {len(purchases)}")
        for po in purchases[:3]:  # First 3
            print(f"PO {po.get('purchase_number')}: vendor_id={po.get('vendor_id')}, vendor_name='{po.get('vendor_name')}', total={po.get('total_amount')}, payment_status='{po.get('payment_status')}'")
except Exception as e:
    print(f"Error: {e}")

print("\n=== Checking Location Stock API ===")
try:
    # Try to find warehouse location ID first
    response = requests.get(f"{base_url}/inventory/locations")
    if response.status_code == 200:
        locations = response.json()
        warehouse = next((loc for loc in locations if 'warehouse' in loc.get('name', '').lower()), None)
        if warehouse:
            warehouse_id = warehouse.get('id')
            print(f"Found warehouse: {warehouse.get('name')} (ID: {warehouse_id})")
            
            # Get stock for this location
            stock_response = requests.get(f"{base_url}/inventory/locations/{warehouse_id}/stock")
            if stock_response.status_code == 200:
                stock = stock_response.json()
                print(f"Stock items count: {len(stock)}")
                for item in stock[:3]:
                    print(f"  Item: {item.get('item_name')}, Qty: {item.get('quantity')}")
            else:
                print(f"Stock API returned: {stock_response.status_code}")
except Exception as e:
    print(f"Error: {e}")
