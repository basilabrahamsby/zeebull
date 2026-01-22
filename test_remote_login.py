import requests
import sys

def test_login():
    url = "http://127.0.0.1:8011/api/auth/login"
    payload = {"email": "admin", "password": "admin123"}
    try:
        r = requests.post(url, json=payload)
        print(f"Status: {r.status_code}")
        print(f"Output: {r.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_login()
