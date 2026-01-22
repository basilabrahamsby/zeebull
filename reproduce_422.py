
import requests

URL = "http://127.0.0.1:8011/api/rooms/test"

data = {
    "number": "999",
    "type": "Test Room",
    "price": "1000",
    "status": "Available",
    "adults": "2",
    "children": "0",
    "air_conditioning": "true",
    "wifi": "false",
    "bathroom": "false",
    "living_area": "false",
    "terrace": "false",
    "parking": "false",
    "kitchen": "false",
    "family_room": "false",
    "bbq": "false",
    "garden": "false",
    "dining": "false",
    "breakfast": "false"
}

# Case 1: No image field
print("--- Sending POST request (No image field) ---")
try:
    resp = requests.post(URL, data=data)
    print(f"Status: {resp.status_code}")
    print(f"Response: {resp.text}")
except Exception as e:
    print(f"Error: {e}")

# Case 2: Image field present but None/Empty? 
# (Requests handles files separately, if we don't pass 'files', it's like missing field)

# Case 3: Pass bools as Python bools (requests converts to strings typically)
print("\n--- Sending POST request (Python bools) ---")
data_bools = data.copy()
data_bools['air_conditioning'] = True
try:
    resp = requests.post(URL, data=data_bools)
    print(f"Status: {resp.status_code}")
    print(f"Response: {resp.text}")
except Exception as e:
    print(f"Error: {e}")
