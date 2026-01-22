import requests
import json
import base64

BASE_URL = "http://localhost:8011/api"

def decode_jwt(token):
    try:
        header, payload, signature = token.split(".")
        # Fix padding if needed
        payload += '=' * (-len(payload) % 4)
        decoded = base64.urlsafe_b64decode(payload)
        return json.loads(decoded)
    except Exception as e:
        print(f"Token decode error: {e}")
        return {}

def check_login():
    print("Attempting login as admin@orchid.com...")
    try:
        resp = requests.post(f"{BASE_URL}/auth/login", json={
            "email": "admin@orchid.com",
            "password": "admin123" 
        })
        if resp.status_code == 200:
            data = resp.json()
            token = data['access_token']
            print("Login Successful.")
            print(f"Token: {token[:20]}...")
            
            payload = decode_jwt(token)
            print("\n--- Token Payload ---")
            print(json.dumps(payload, indent=2))
            
            if 'employee_id' in payload:
                print(f"\nSUCCESS: employee_id is present: {payload['employee_id']}")
            else:
                print("\nFAILURE: employee_id is MISSING from token!")
                
        else:
            print(f"Login failed: {resp.status_code} {resp.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    check_login()
