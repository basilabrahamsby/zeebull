
import requests
import json

BASE_URL = "http://127.0.0.1:8011"
AUTH_URL = f"{BASE_URL}/api/auth/login"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def reproduce_empty_int():
    print("--- Authenticating ---")
    try:
        token = requests.post(AUTH_URL, json={"email": "admin", "password": "admin123"}).json()["access_token"]
    except Exception as e:
        print(f"Auth failed: {e}")
        return
        
    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Sending POST request with EMPTY adults string ---")
    data = {
        "number": "102", # New number to avoid 500
        "type": "Test",
        "price": "100",
        "status": "Available",
        "adults": "", # The culprit?
        "children": "0",
        "air_conditioning": "false"
    }
    
    files = {'dummy': (None, 'dummy')} # Multipart force
    
    try:
        resp = requests.post(TEST_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        print(f"Response Body: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce_empty_int()
