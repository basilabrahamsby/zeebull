# Activity Logs - Access Guide (Updated)

## ⚠️ Current Status

The Activity Logs API endpoint is temporarily disabled due to an import issue. 

**You can still access activity logs via direct database queries.**

## ✅ How to Access Activity Logs

### Method 1: Direct Database Query (Recommended)

**Step 1: SSH into the server**
```bash
ssh -i ~/.ssh/gcp_key basilabrahamaby@136.113.93.47
```

**Step 2: Connect to PostgreSQL**
```bash
sudo -u postgres psql orchid_resort
```

**Step 3: Query the logs**

**Get last 50 logs:**
```sql
SELECT 
  id,
  method,
  path,
  status_code,
  client_ip,
  user_id,
  details,
  timestamp
FROM activity_logs 
ORDER BY timestamp DESC 
LIMIT 50;
```

**Get only errors (status >= 400):**
```sql
SELECT * FROM activity_logs 
WHERE status_code >= 400 
ORDER BY timestamp DESC 
LIMIT 50;
```

**Get room creation attempts:**
```sql
SELECT * FROM activity_logs 
WHERE path LIKE '%rooms%' 
AND method = 'POST'
ORDER BY timestamp DESC 
LIMIT 50;
```

**Get food item creation attempts:**
```sql
SELECT * FROM activity_logs 
WHERE path LIKE '%food-items%' 
ORDER BY timestamp DESC 
LIMIT 50;
```

**Get logs from last 24 hours:**
```sql
SELECT * FROM activity_logs 
WHERE timestamp >= NOW() - INTERVAL '24 hours'
ORDER BY timestamp DESC;
```

**Get statistics:**
```sql
-- Total requests
SELECT COUNT(*) as total_requests FROM activity_logs;

-- Success rate
SELECT 
  COUNT(CASE WHEN status_code < 400 THEN 1 END) as successful,
  COUNT(CASE WHEN status_code >= 400 THEN 1 END) as errors,
  ROUND(COUNT(CASE WHEN status_code < 400 THEN 1 END)::numeric / COUNT(*)::numeric * 100, 2) as success_rate
FROM activity_logs;

-- Most common endpoints
SELECT 
  path,
  COUNT(*) as request_count
FROM activity_logs 
GROUP BY path 
ORDER BY request_count DESC 
LIMIT 10;

-- Most common status codes
SELECT 
  status_code,
  COUNT(*) as count
FROM activity_logs 
GROUP BY status_code 
ORDER BY count DESC;
```

### Method 2: Create a Simple Query Script

Create a file `view_logs.sh` on the server:

```bash
#!/bin/bash
sudo -u postgres psql orchid_resort -c "
SELECT 
  TO_CHAR(timestamp, 'YYYY-MM-DD HH24:MI:SS') as time,
  method,
  path,
  status_code,
  client_ip
FROM activity_logs 
ORDER BY timestamp DESC 
LIMIT 50;
"
```

Make it executable:
```bash
chmod +x view_logs.sh
```

Run it anytime:
```bash
./view_logs.sh
```

### Method 3: Export to CSV

```bash
sudo -u postgres psql orchid_resort -c "
COPY (
  SELECT * FROM activity_logs 
  ORDER BY timestamp DESC 
  LIMIT 1000
) TO '/tmp/activity_logs.csv' CSV HEADER;
"

# Download the file
scp basilabrahamaby@136.113.93.47:/tmp/activity_logs.csv ./activity_logs.csv
```

## 📊 What's in the Activity Logs

Each log entry contains:
- **id**: Unique identifier
- **action**: Full action description (e.g., "POST /api/rooms/test")
- **method**: HTTP method (GET, POST, PUT, DELETE)
- **path**: API endpoint path
- **status_code**: HTTP status code (200, 400, 422, 500, etc.)
- **client_ip**: IP address of the client
- **user_id**: ID of authenticated user (NULL if not logged in)
- **details**: Additional information (e.g., "Duration: 0.0234s")
- **timestamp**: When the request was made

## 🔍 Common Queries

### Find Recent 422 Errors
```sql
SELECT * FROM activity_logs 
WHERE status_code = 422 
AND timestamp >= NOW() - INTERVAL '1 hour'
ORDER BY timestamp DESC;
```

### Monitor Room Creation
```sql
SELECT 
  timestamp,
  status_code,
  client_ip,
  details
FROM activity_logs 
WHERE path = '/api/rooms/test' 
AND method = 'POST'
ORDER BY timestamp DESC 
LIMIT 20;
```

### Check User Activity
```sql
SELECT * FROM activity_logs 
WHERE user_id = 1 
AND timestamp >= NOW() - INTERVAL '24 hours'
ORDER BY timestamp DESC;
```

### Find Slow Requests
```sql
SELECT * FROM activity_logs 
WHERE details LIKE '%Duration:%'
ORDER BY timestamp DESC 
LIMIT 50;
```

## 📝 Notes

- Activity logging is **working** - all requests are being logged
- The API endpoint is temporarily disabled
- You can access all logs via direct database queries
- Logs are automatically created by the `ActivityLoggingMiddleware`
- Static file requests are NOT logged (to save space)

## 🎯 Next Steps

For now, use the direct database queries to access activity logs. The API endpoint will be fixed in a future update.

If you need help with any specific query, let me know!
