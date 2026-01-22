import requests
import json

url = "http://136.113.93.47:8011/api/inventory/purchases?status=received"
response = requests.get(url)

if response.status_code == 200:
    data = response.json()
    for purchase in data:
        if purchase.get('purchase_number') == 'PO-20260111-0001':
            print("Found PO-20260111-0001:")
            print(f"  ID: {purchase.get('id')}")
            print(f"  Vendor ID: {purchase.get('vendor_id')}")
            print(f"  Vendor Name: {purchase.get('vendor_name')}")
            print(f"  Total Amount: {purchase.get('total_amount')}")
            print(f"  Sub Total: {purchase.get('sub_total')}")
            print(f"  CGST: {purchase.get('cgst')}")
            print(f"  SGST: {purchase.get('sgst')}")
            print(f"  Payment Status: {purchase.get('payment_status')}")
            print(f"  Status: {purchase.get('status')}")
            break
    else:
        print("PO-20260111-0001 not found in response")
        print(f"Total purchases returned: {len(data)}")
else:
    print(f"Error: {response.status_code}")
    print(response.text)
