
import requests

BASE_URL = "http://127.0.0.1:8011"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def test_with_string_booleans():
    print("--- Authenticating ---")
    try:
        resp = requests.post(f"{BASE_URL}/api/auth/login", json={"email": "admin", "password": "admin123"})
        token = resp.json().get("access_token")
    except:
        print("Auth failed")
        return

    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Testing with string booleans (like frontend sends) ---")
    data = {
        "number": "109", 
        "type": "AC",
        "price": "2000", 
        "status": "Available",
        "adults": "2", 
        "children": "2", 
        "air_conditioning": "true",  # String boolean
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
        'image': ('test_image.jpg', b'fake image content', 'image/jpeg')
    }
    
    try:
        resp = requests.post(TEST_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        if resp.status_code == 200:
            print("SUCCESS! Room created")
            print(f"Response: {resp.json()}")
        else:
            print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_with_string_booleans()
