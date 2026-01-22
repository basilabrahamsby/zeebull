
import requests

BASE_URL = "http://127.0.0.1:8011"
AUTH_URL = f"{BASE_URL}/api/auth/login"
CATEGORY_URL = f"{BASE_URL}/api/food-categories"

def test_food_category_creation():
    print("=== Testing Food Category Creation ===\n")
    
    # 1. Authenticate
    print("1. Authenticating...")
    try:
        resp = requests.post(AUTH_URL, json={"email": "admin", "password": "admin123"})
        if resp.status_code != 200:
            print(f"❌ Auth failed: {resp.text}")
            return
        token = resp.json().get("access_token")
        print(f"✅ Authenticated successfully")
    except Exception as e:
        print(f"❌ Auth error: {e}")
        return

    headers = {"Authorization": f"Bearer {token}"}

    # 2. Test creating category with FormData
    print("\n2. Creating food category with image...")
    
    data = {
        "name": "Test Category"
    }
    
    files = {
        'image': ('test_category.jpg', b'fake image data', 'image/jpeg')
    }
    
    try:
        resp = requests.post(CATEGORY_URL, data=data, files=files, headers=headers)
        print(f"Status: {resp.status_code}")
        
        if resp.status_code == 200 or resp.status_code == 201:
            print("✅ SUCCESS! Category created")
            print(f"Response: {resp.json()}")
        else:
            print(f"❌ FAILED")
            print(f"Response: {resp.text}")
    except Exception as e:
        print(f"❌ Error: {e}")

    # 3. Test creating category without image (should fail if image is required)
    print("\n3. Creating food category WITHOUT image...")
    
    data = {
        "name": "Test Category 2"
    }
    
    try:
        resp = requests.post(CATEGORY_URL, data=data, headers=headers)
        print(f"Status: {resp.status_code}")
        
        if resp.status_code == 200 or resp.status_code == 201:
            print("✅ SUCCESS! Category created without image")
            print(f"Response: {resp.json()}")
        else:
            print(f"Response: {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_food_category_creation()
