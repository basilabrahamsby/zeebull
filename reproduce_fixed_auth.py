
import requests

BASE_URL = "http://127.0.0.1:8011"
AUTH_URL = f"{BASE_URL}/api/auth/login"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def reproduce_fixed_payload_auth():
    print("--- Authenticating ---")
    try:
        resp = requests.post(AUTH_URL, json={"email": "admin", "password": "admin123"})
        if resp.status_code != 200:
            print(f"Login failed: {resp.text}")
            return
        token = resp.json().get("access_token")
    except Exception as e:
        print(f"Auth error: {e}")
        return

    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Sending POST request with FIXED payload ---")
    data = {
        "number": "106", 
        "type": "Test Room",
        "price": "0", 
        "status": "Available",
        "adults": "2", 
        "children": "0", 
        "air_conditioning": "false"
    }
    files = {'dummy': (None, 'dummy')}
    
    try:
        resp = requests.post(TEST_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce_fixed_payload_auth()
