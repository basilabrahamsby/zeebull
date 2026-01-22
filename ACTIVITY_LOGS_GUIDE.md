# Activity Logs - Access Guide

## API Endpoints

The activity logs are now accessible via REST API endpoints.

### Base URL
- **Production**: `https://teqmates.com/orchidapi/api`
- **Local**: `http://localhost:8011/api`

### Authentication Required
All endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <your_token>
```

## 📊 Available Endpoints

### 1. Get Activity Logs
**GET** `/activity-logs`

Retrieve activity logs with optional filters and pagination.

#### Query Parameters:
- `skip` (int, default: 0): Number of records to skip (pagination)
- `limit` (int, default: 100, max: 1000): Maximum records to return
- `method` (string): Filter by HTTP method (GET, POST, PUT, DELETE)
- `path` (string): Filter by path (partial match)
- `status_code` (int): Filter by status code (200, 400, 422, 500, etc.)
- `user_id` (int): Filter by user ID
- `hours` (int): Get logs from last N hours

#### Examples:

**Get last 50 logs:**
```
GET /activity-logs?limit=50
```

**Get all 422 errors:**
```
GET /activity-logs?status_code=422&limit=100
```

**Get room-related requests:**
```
GET /activity-logs?path=rooms&limit=50
```

**Get logs from last 24 hours:**
```
GET /activity-logs?hours=24&limit=100
```

**Get POST requests only:**
```
GET /activity-logs?method=POST&limit=50
```

#### Response Format:
```json
{
  "total": 150,
  "skip": 0,
  "limit": 50,
  "logs": [
    {
      "id": 1,
      "action": "POST /api/rooms/test",
      "method": "POST",
      "path": "/api/rooms/test",
      "status_code": 200,
      "client_ip": "192.168.1.100",
      "user_id": 1,
      "details": "Duration: 0.0234s",
      "timestamp": "2026-01-09T16:30:00.000Z"
    },
    ...
  ]
}
```

### 2. Get Activity Statistics
**GET** `/activity-logs/stats`

Get aggregated statistics about activity.

#### Query Parameters:
- `hours` (int, default: 24): Get stats from last N hours

#### Example:
```
GET /activity-logs/stats?hours=24
```

#### Response Format:
```json
{
  "period_hours": 24,
  "total_requests": 1500,
  "successful_requests": 1350,
  "error_requests": 150,
  "success_rate": 90.0,
  "error_rate": 10.0,
  "top_endpoints": [
    {"path": "/api/rooms/", "count": 450},
    {"path": "/api/bookings", "count": 300},
    ...
  ],
  "status_codes": [
    {"code": 200, "count": 1200},
    {"code": 422, "count": 80},
    {"code": 404, "count": 50},
    ...
  ]
}
```

## 🔧 How to Use

### Option 1: Using Browser (API Documentation)

1. Go to: `https://teqmates.com/orchidapi/docs`
2. Click on "Activity Logs" section
3. Try out the endpoints with the interactive UI
4. You'll need to authenticate first using the `/api/auth/login` endpoint

### Option 2: Using cURL

**Get last 50 logs:**
```bash
# First, login to get token
curl -X POST https://teqmates.com/orchidapi/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin","password":"admin123"}'

# Use the token from response
curl -X GET "https://teqmates.com/orchidapi/api/activity-logs?limit=50" \
  -H "Authorization: Bearer <your_token>"
```

**Get statistics:**
```bash
curl -X GET "https://teqmates.com/orchidapi/api/activity-logs/stats?hours=24" \
  -H "Authorization: Bearer <your_token>"
```

### Option 3: Using Python

```python
import requests

# Login
response = requests.post(
    "https://teqmates.com/orchidapi/api/auth/login",
    json={"email": "admin", "password": "admin123"}
)
token = response.json()["access_token"]

# Get activity logs
headers = {"Authorization": f"Bearer {token}"}
response = requests.get(
    "https://teqmates.com/orchidapi/api/activity-logs",
    headers=headers,
    params={"limit": 50, "hours": 24}
)
logs = response.json()
print(f"Total logs: {logs['total']}")
for log in logs['logs']:
    print(f"{log['timestamp']} - {log['method']} {log['path']} - {log['status_code']}")
```

### Option 4: Using Postman

1. Create a new request
2. Set method to GET
3. URL: `https://teqmates.com/orchidapi/api/activity-logs`
4. Add header: `Authorization: Bearer <your_token>`
5. Add query parameters as needed
6. Send request

### Option 5: Direct Database Query (SSH Access Required)

```bash
# SSH into server
ssh -i ~/.ssh/gcp_key basilabrahamaby@136.113.93.47

# Connect to database
sudo -u postgres psql orchid_resort

# Query activity logs
SELECT * FROM activity_logs 
ORDER BY timestamp DESC 
LIMIT 50;

# Get error logs only
SELECT * FROM activity_logs 
WHERE status_code >= 400 
ORDER BY timestamp DESC 
LIMIT 50;

# Get room creation attempts
SELECT * FROM activity_logs 
WHERE path LIKE '%rooms%' 
AND method = 'POST'
ORDER BY timestamp DESC 
LIMIT 50;
```

## 📋 Common Use Cases

### 1. Debug Recent Errors
```
GET /activity-logs?status_code=422&hours=1&limit=20
```

### 2. Monitor Room Creation
```
GET /activity-logs?path=rooms/test&method=POST&hours=24
```

### 3. Check User Activity
```
GET /activity-logs?user_id=1&hours=24&limit=100
```

### 4. Get Daily Statistics
```
GET /activity-logs/stats?hours=24
```

### 5. Find Slow Requests
Look for logs with high duration in the `details` field.

## 📊 What's Logged

Every API request is logged with:
- ✅ **Action**: HTTP method + path
- ✅ **Method**: GET, POST, PUT, DELETE, etc.
- ✅ **Path**: API endpoint path
- ✅ **Status Code**: 200, 400, 422, 500, etc.
- ✅ **Client IP**: IP address of the client
- ✅ **User ID**: ID of authenticated user (if logged in)
- ✅ **Details**: Additional info like request duration
- ✅ **Timestamp**: When the request was made

## 🚫 What's NOT Logged

To prevent database bloat, these are excluded:
- Static file requests (`/uploads`, `/static`, etc.)
- Health check requests (`/health`)
- Favicon requests

## 🎯 Next Steps

1. **Try the API**: Go to `https://teqmates.com/orchidapi/docs`
2. **Login**: Use `/api/auth/login` endpoint
3. **View Logs**: Use `/api/activity-logs` endpoint
4. **Get Stats**: Use `/api/activity-logs/stats` endpoint

You can also create a dashboard page to display these logs in a nice UI if needed!
