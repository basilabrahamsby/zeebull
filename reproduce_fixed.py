
import requests

URL = "http://127.0.0.1:8011/api/rooms/test"

def reproduce_fixed_payload():
    print("--- Sending POST request with FIXED payload ---")
    
    # Simulating the fixed CreateRooms.jsx
    data = {
        "number": "105", # Unique
        "type": "Test Room",
        "price": "0", # Default fallback
        "status": "Available",
        "adults": "2", # Default fallback
        "children": "0", # Default fallback
        "air_conditioning": "false",
        "wifi": "false"
        # ... other bools assumed false/missing
    }
    
    # Simulate missing image (no 'image' key in files)
    files = {'dummy_force_multipart': (None, 'dummy')}
    
    try:
        resp = requests.post(URL, data=data, files=files)
        print(f"Status: {resp.status_code}")
        print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce_fixed_payload()
