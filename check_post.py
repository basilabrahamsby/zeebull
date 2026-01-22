import requests
try:
    print("Testing POST /api/employees (No Slash)")
    r = requests.post('http://localhost:8011/api/employees')
    print(f"Status: {r.status_code}")
except Exception as e:
    print(f"Error 1: {e}")

try:
    print("Testing POST /api/employees/ (With Slash)")
    r = requests.post('http://localhost:8011/api/employees/')
    print(f"Status: {r.status_code}")
except Exception as e:
    print(f"Error 2: {e}")
