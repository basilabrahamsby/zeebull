#!/usr/bin/env python3
import requests
import json

url = "http://localhost:8011/api/auth/login"
data = {
    "email": "test@orchid.com",
    "password": "test123"
}

print("Testing login with:")
print(f"Email: {data['email']}")
print(f"Password: {data['password']}")
print()

try:
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 200:
        print("\n✅ LOGIN SUCCESSFUL!")
        result = response.json()
        if 'access_token' in result:
            print(f"Access Token: {result['access_token'][:50]}...")
    else:
        print("\n❌ LOGIN FAILED!")
        
except Exception as e:
    print(f"Error: {e}")
