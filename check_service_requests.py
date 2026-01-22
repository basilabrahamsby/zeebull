import requests
import json

BASE_URL = "http://localhost:8011/api"

def get_token():
    print("Logging in...")
    try:
        resp = requests.post(f"{BASE_URL}/auth/login", json={
            "email": "admin@orchid.com",
            "password": "admin123" 
        })
        if resp.status_code == 200:
            return resp.json()['access_token']
        else:
            print(f"Login failed: {resp.status_code} {resp.text}")
            return None
    except Exception as e:
        print(f"Login error: {e}")
        return None

def check_requests(token):
    print("Checking active requests...")
    headers = {"Authorization": f"Bearer {token}"}
    try:
        resp = requests.get(f"{BASE_URL}/service-requests?limit=10", headers=headers)
        if resp.status_code == 200:
            data = resp.json()
            print(f"Active Requests Count: {len(data)}")
            for item in data:
                print("--- Request Item ---")
                print(json.dumps(item, indent=2))
        else:
            print(f"Failed to get active requests. Status: {resp.status_code}")
            print(resp.text)
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    token = get_token()
    if token:
        check_requests(token)
