
import requests
import json

BASE_URL = "http://127.0.0.1:8011"
AUTH_URL = f"{BASE_URL}/api/auth/login"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def reproduce():
    # 1. Login
    print("--- Authenticating ---")
    login_payload = {
        "email": "admin", # Assuming email is admin? Or admin@example.com?
        # The frontend says "Logged in as: admin".
        # Let's try username/email permutations if 'admin' fails.
        "password": "admin123" 
    }
    
    # Try logging in with 'admin', 'admin@gmail.com', 'admin@example.com'
    token = None
    for email in ["admin", "admin@gmail.com", "admin@teqmates.com"]:
        login_payload["email"] = email
        try:
            resp = requests.post(AUTH_URL, json=login_payload)
            if resp.status_code == 200:
                print(f"Login successful with '{email}'")
                token = resp.json().get("access_token")
                break
            else:
                print(f"Login failed for '{email}': {resp.status_code} {resp.text}")
        except Exception as e:
            print(f"Request failed: {e}")
            
    if not token:
        print("Could not obtain token. Aborting.")
        return

    headers = {
        "Authorization": f"Bearer {token}"
    }

    # 2. Send 422 Payload
    print("\n--- Sending POST request to /rooms/test ---")
    
    # Emulate the FormData sent by browser
    # Based on CreateRooms.jsx
    data = {
        "number": "101",
        "type": "Deluxe",
        "price": "1300",
        "status": "Available",
        "adults": "2",
        "children": "2",
        # "image": (None)
        "air_conditioning": "false",
        "wifi": "true",
        "bathroom": "true", 
        "living_area": "false",
        "terrace": "false",
        "parking": "true",
        "kitchen": "false",
        "family_room": "false",
        "bbq": "false",
        "garden": "false",
        "dining": "false",
        "breakfast": "false"
    }

    try:
        resp = requests.post(TEST_URL, data=data, headers=headers)
        print(f"Status: {resp.status_code}")
        print(f"Response Headers: {resp.headers}")
        print(f"Response Body: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce()
