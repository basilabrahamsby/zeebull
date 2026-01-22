
import requests

BASE_URL = "http://127.0.0.1:8011"
AUTH_URL = f"{BASE_URL}/api/auth/login"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def reproduce_fail():
    print("--- Authenticating ---")
    try:
        resp = requests.post(AUTH_URL, json={"email": "admin", "password": "admin123"})
        token = resp.json().get("access_token")
    except:
        return

    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Sending FAIL payload (price='') ---")
    data = {
        "number": "999", 
        "type": "Test Room",
        "price": "",  # Expecting 422
        "status": "Available",
        "adults": "2", 
        "children": "0", 
        "air_conditioning": "false"
    }
    # multipart
    files = {'dummy': (None, 'dummy')}
    
    try:
        resp = requests.post(TEST_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce_fail()
