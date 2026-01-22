import requests
import sys

# Try localhost first (Server internal)
BASE_URL = "http://localhost:8011/api"

def check():
    try:
        # 1. Login
        print(f"Attempting Login to {BASE_URL}...")
        # Mobile app uses /auth/login with JSON email/password
        resp = requests.post(f"{BASE_URL}/auth/login", json={"email": "alphi@orchid.com", "password": "12345678"})
        
        if resp.status_code != 200:
            print(f"Login JSON failed: {resp.status_code}. Trying Form /token...")
            resp = requests.post(f"{BASE_URL}/auth/token", data={"username": "alphi@orchid.com", "password": "12345678"})
            
        if resp.status_code != 200:
            print(f"LOGIN FAILED. Status: {resp.status_code}. Response: {resp.text}")
            return

        data = resp.json()
        token = data.get("access_token")
        if not token:
            print("No access token in response.")
            return
            
        print("Login Successful.")
        
        # 2. Check /employees/me
        print("Checking GET /employees/me...")
        headers = {"Authorization": f"Bearer {token}"}
        resp_me = requests.get(f"{BASE_URL}/employees/me", headers=headers, timeout=5)
        
        print(f"Status Code: {resp_me.status_code}")
        print(f"Response Body: {resp_me.text}")
        
        if resp_me.status_code == 404:
            print("\n>>> DIAGNOSIS: SERVER NOT RESTARTED. Endpoint missing. <<<")
        elif resp_me.status_code == 200:
             print("\n>>> DIAGNOSIS: SERVER UPDATED & WORKING. Mobile App needs restart. <<<")
        else:
             print(f"\n>>> DIAGNOSIS: Endpoint returns error {resp_me.status_code}. <<<")

    except Exception as e:
        print(f"Connection Error: {e}")

if __name__ == "__main__":
    check()
