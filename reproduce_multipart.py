
import requests
import json

BASE_URL = "http://127.0.0.1:8011"
AUTH_URL = f"{BASE_URL}/api/auth/login"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def reproduce_multipart():
    print("--- Authenticating ---")
    try:
        token = requests.post(AUTH_URL, json={"email": "admin", "password": "admin123"}).json()["access_token"]
    except Exception as e:
        print(f"Auth failed: {e}")
        return
        
    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Sending MULTIPART POST request (Missing 'image') ---")
    data = {
        "number": "101",
        "type": "Deluxe",
        "price": "1300",
        "status": "Available",
        "adults": "2",
        "children": "2",
        "air_conditioning": "false",
        "wifi": "true"
    }
    
    # We include a dummy file to force requests to use multipart/form-data.
    # The 'image' field is INTENTIONALLY OMITTED to simulate the frontend behavior when image is null.
    files = {
        'dummy_trigger': (None, 'dummy') 
    }
    
    try:
        resp = requests.post(TEST_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        print(f"Response Body: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce_multipart()
