# Activity Logs - Quick Access Guide

## ✅ Activity Logs API is Now Available!

I've created REST API endpoints for you to access all activity logs.

## 🚀 Quick Start

### Option 1: Using API Documentation (Easiest)

1. **Go to**: https://teqmates.com/orchidapi/docs
2. **Find**: "Activity Logs" section
3. **Authenticate**: 
   - Click on `/api/auth/login`
   - Click "Try it out"
   - Enter: `{"email":"admin","password":"admin123"}`
   - Click "Execute"
   - Copy the `access_token` from the response
4. **Authorize**:
   - Click the "Authorize" button at the top
   - Enter: `Bearer <paste_your_token_here>`
   - Click "Authorize"
5. **View Logs**:
   - Click on `/api/activity-logs` → GET
   - Click "Try it out"
   - Set parameters (e.g., `limit: 50`)
   - Click "Execute"
   - See the results!

### Option 2: Using Browser Console

Open your browser console (F12) and run:

```javascript
// 1. Login
fetch('https://teqmates.com/orchidapi/api/auth/login', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({email: 'admin', password: 'admin123'})
})
.then(r => r.json())
.then(data => {
  const token = data.access_token;
  
  // 2. Get activity logs
  return fetch('https://teqmates.com/orchidapi/api/activity-logs?limit=50', {
    headers: {'Authorization': `Bearer ${token}`}
  });
})
.then(r => r.json())
.then(logs => {
  console.log('Total logs:', logs.total);
  console.table(logs.logs);
});
```

### Option 3: Direct Database Query (SSH Required)

```bash
# SSH into server
ssh -i ~/.ssh/gcp_key basilabrahamaby@136.113.93.47

# Connect to database
sudo -u postgres psql orchid_resort

# View recent logs
SELECT 
  id,
  method,
  path,
  status_code,
  client_ip,
  timestamp
FROM activity_logs 
ORDER BY timestamp DESC 
LIMIT 50;

# View only errors
SELECT * FROM activity_logs 
WHERE status_code >= 400 
ORDER BY timestamp DESC 
LIMIT 50;

# View room creation attempts
SELECT * FROM activity_logs 
WHERE path LIKE '%rooms%' 
AND method = 'POST'
ORDER BY timestamp DESC;
```

## 📊 Available Endpoints

### 1. Get Logs
**GET** `/api/activity-logs`

**Parameters:**
- `limit` (default: 100): How many logs to return
- `skip` (default: 0): Skip N logs (for pagination)
- `method`: Filter by HTTP method (GET, POST, PUT, DELETE)
- `path`: Filter by path (e.g., "rooms", "food-categories")
- `status_code`: Filter by status (200, 422, 500, etc.)
- `hours`: Get logs from last N hours

**Examples:**
- Last 50 logs: `?limit=50`
- All 422 errors: `?status_code=422&limit=100`
- Room requests: `?path=rooms&limit=50`
- Last 24 hours: `?hours=24`

### 2. Get Statistics
**GET** `/api/activity-logs/stats`

**Parameters:**
- `hours` (default: 24): Get stats from last N hours

**Returns:**
- Total requests
- Success rate
- Error rate
- Top endpoints
- Status code distribution

## 📋 What's Logged

Every API request includes:
- ✅ **Method**: GET, POST, PUT, DELETE
- ✅ **Path**: /api/rooms/test, /api/food-categories, etc.
- ✅ **Status Code**: 200, 400, 422, 500
- ✅ **Client IP**: Who made the request
- ✅ **User ID**: If authenticated
- ✅ **Duration**: How long it took
- ✅ **Timestamp**: When it happened

## 🎯 Common Queries

### Find Recent Errors
```
GET /api/activity-logs?status_code=422&hours=1&limit=20
```

### Monitor Room Creation
```
GET /api/activity-logs?path=rooms/test&method=POST&hours=24
```

### Check User Activity
```
GET /api/activity-logs?user_id=1&hours=24
```

### Get Daily Stats
```
GET /api/activity-logs/stats?hours=24
```

## 🔧 Testing

You can test the API right now:

1. Go to: https://teqmates.com/orchidapi/docs
2. Scroll to "Activity Logs" section
3. Try the endpoints!

## 📝 Notes

- All endpoints require authentication
- Logs are stored in the `activity_logs` database table
- Static file requests are NOT logged (to save space)
- Logs are ordered by most recent first

## 🎉 That's It!

The activity logs are fully functional and ready to use. You can:
- ✅ View all API requests
- ✅ Filter by method, path, status, user
- ✅ Get statistics
- ✅ Debug errors
- ✅ Monitor user activity

For detailed documentation, see: `ACTIVITY_LOGS_GUIDE.md`
