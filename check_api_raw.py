import requests
import json
import datetime

# Replace with actual URL found in api_constants.dart if different
BASE_URL = "https://teqmates.com/orchidapi/api"
EMPLOYEE_ID = 26 # Using a likely ID, or I should find the ID of the user logged in. 
# Actually, I'll list logs for a few IDs to find the recent one.

def check_attendance(emp_id):
    try:
        url = f"{BASE_URL}/attendance/work-logs/{emp_id}"
        print(f"Checking {url}...")
        response = requests.get(url)
        if response.status_code == 200:
            logs = response.json()
            if logs:
                print(f"Logs for Employee {emp_id}:")
                for log in logs[:1]: # Just the latest
                    print(json.dumps(log, indent=2))
            else:
                print(f"No logs for {emp_id}")
        else:
            print(f"Error {response.status_code}: {response.text}")
    except Exception as e:
        print(f"Failed to connect: {e}")

# Check for a range of IDs to hit the active one
for i in range(1, 40):
    check_attendance(i)
