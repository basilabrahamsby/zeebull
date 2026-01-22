import requests

BASE_URL = "http://127.0.0.1:8011"

def test_activity_logs():
    print("=== Testing Activity Logs API ===\n")
    
    # 1. Login
    print("1. Logging in...")
    resp = requests.post(f"{BASE_URL}/api/auth/login", json={"email": "admin", "password": "admin123"})
    if resp.status_code != 200:
        print(f"❌ Login failed: {resp.text}")
        return
    
    token = resp.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Logged in successfully\n")
    
    # 2. Get recent logs
    print("2. Getting last 10 activity logs...")
    resp = requests.get(f"{BASE_URL}/api/activity-logs", headers=headers, params={"limit": 10})
    if resp.status_code == 200:
        data = resp.json()
        print(f"✅ Total logs: {data['total']}")
        print(f"   Showing: {len(data['logs'])} logs\n")
        
        for log in data['logs'][:5]:  # Show first 5
            print(f"   [{log['timestamp']}] {log['method']} {log['path']} - {log['status_code']}")
    else:
        print(f"❌ Failed: {resp.text}")
    
    # 3. Get statistics
    print("\n3. Getting activity statistics (last 24 hours)...")
    resp = requests.get(f"{BASE_URL}/api/activity-logs/stats", headers=headers, params={"hours": 24})
    if resp.status_code == 200:
        stats = resp.json()
        print(f"✅ Statistics:")
        print(f"   Total requests: {stats['total_requests']}")
        print(f"   Successful: {stats['successful_requests']} ({stats['success_rate']}%)")
        print(f"   Errors: {stats['error_requests']} ({stats['error_rate']}%)")
        print(f"\n   Top 5 endpoints:")
        for endpoint in stats['top_endpoints'][:5]:
            print(f"   - {endpoint['path']}: {endpoint['count']} requests")
    else:
        print(f"❌ Failed: {resp.text}")
    
    # 4. Filter by status code
    print("\n4. Getting error logs (status >= 400)...")
    resp = requests.get(f"{BASE_URL}/api/activity-logs", headers=headers, params={"status_code": 422, "limit": 5})
    if resp.status_code == 200:
        data = resp.json()
        print(f"✅ Found {data['total']} logs with status 422")
        for log in data['logs']:
            print(f"   [{log['timestamp']}] {log['method']} {log['path']}")
    else:
        print(f"❌ Failed: {resp.text}")

if __name__ == "__main__":
    test_activity_logs()
