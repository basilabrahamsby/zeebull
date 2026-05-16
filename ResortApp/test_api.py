
import requests

try:
    r = requests.get("http://localhost:8011/api/day-audit/current")
    print(f"Status: {r.status_code}")
    print(f"Body: {r.text}")
except Exception as e:
    print(f"Error: {e}")

try:
    r = requests.get("http://localhost:8011/health")
    print(f"Health Status: {r.status_code}")
    print(f"Health Body: {r.text}")
except Exception as e:
    print(f"Health Error: {e}")
