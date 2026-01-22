import requests
import json

def test_api():
    url = "https://teqmates.com/api/bill/checkouts/1/details"
    try:
        # We might need authentication
        # But let's see if we get a 401 or something else
        response = requests.get(url, verify=False)
        print(f"Status: {response.status_code}")
        print(f"Body: {response.text[:500]}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_api()
