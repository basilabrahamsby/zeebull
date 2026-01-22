
import requests

BASE_URL = "http://127.0.0.1:8011"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def reproduce_user_case():
    print("--- Authenticating ---")
    try:
        resp = requests.post(f"{BASE_URL}/api/auth/login", json={"email": "admin", "password": "admin123"})
        token = resp.json().get("access_token")
    except:
        print("Auth failed")
        return

    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Sending USER payload ---")
    data = {
        "number": "108", 
        "type": "AC",
        "price": "2000", 
        "status": "Available",
        "adults": "2", 
        "children": "2", 
        "air_conditioning": "true",
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
    
    # Simulate file upload
    files = {
        'image': ('test_image.txt', b'fake image content', 'text/plain')
    }
    
    try:
        resp = requests.post(TEST_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce_user_case()
