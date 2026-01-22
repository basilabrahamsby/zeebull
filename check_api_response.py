import requests
import json

url = "https://teqmates.com/orchidapi/api/service-requests?limit=20"
headers = {"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoyNywicm9sZSI6IkhvdXNla2VlcGluZyIsImVtcGxveWVlX2lkIjo0LCJleHAiOjE3Njg4Nzk0MzJ9.maZ7muX7XAGr9Xag94KF6GS30dYMOvBjbYCtyqVbYYQ"}

try:
    resp = requests.get(url, headers=headers)
    print(f"Status: {resp.status_code}")
    data = resp.json()
    found = False
    for item in data:
        if item.get('type') == 'dj night' or item.get('request_type') == 'dj night':
            found = True
            print("Found dj night:")
            # Check if refill_data is present
            if 'refill_data' in item:
                print(f"refill_data content: {json.dumps(item['refill_data'])}")
            else:
                print("refill_data key MISSING (Backend not updated?)")
    
    if not found:
        print("Did not find 'dj night' in latest 20 requests. Maybe fetch more?")

except Exception as e:
    print(e)
