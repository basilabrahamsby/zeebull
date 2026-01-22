
import requests

BASE_URL = "http://127.0.0.1:8011"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def test_exact_frontend_payload():
    print("--- Authenticating ---")
    try:
        resp = requests.post(f"{BASE_URL}/api/auth/login", json={"email": "admin", "password": "admin123"})
        if resp.status_code != 200:
            print(f"Auth failed: {resp.text}")
            return
        token = resp.json().get("access_token")
        print(f"Token: {token[:20]}...")
    except Exception as e:
        print(f"Auth error: {e}")
        return

    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Testing EXACT frontend payload (Room 103) ---")
    data = {
        "number": "103", 
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
    
    # Test WITHOUT image first
    print("\n=== Test 1: WITHOUT image ===")
    try:
        resp = requests.post(TEST_URL, data=data, headers=headers)
        print(f"Status: {resp.status_code}")
        if resp.status_code == 200:
            print("✅ SUCCESS! Room created without image")
            print(f"Response: {resp.json()}")
        else:
            print(f"❌ FAILED")
            print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Test WITH image
    print("\n=== Test 2: WITH image ===")
    data["number"] = "104"  # Different room number
    files = {
        'image': ('test_room.jpg', b'fake image data', 'image/jpeg')
    }
    
    try:
        resp = requests.post(TEST_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        if resp.status_code == 200:
            print("✅ SUCCESS! Room created with image")
            print(f"Response: {resp.json()}")
        else:
            print(f"❌ FAILED")
            print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_exact_frontend_payload()
