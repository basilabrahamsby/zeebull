from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request
from app.database import SessionLocal
from app.models.activity_log import ActivityLog
import jwt
import os
import time

class ActivityLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        
        # Process Request
        response = await call_next(request)
        
        # Log after response (Background task ideal, but here for simplicity)
        # We process logging asynchronously or in a way that doesn't block response?
        # Starlette middleware has to await response.
        
        process_time = time.time() - start_time
        
        # Extract User
        user_id = None
        auth_header = request.headers.get("Authorization")
        if auth_header and auth_header.startswith("Bearer "):
            token = auth_header.split(" ")[1]
            try:
                # Basic decode (without validation or with? Middleware validation might fail)
                # We just want ID.
                SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key")
                ALGORITHM = os.getenv("ALGORITHM", "HS256")
                payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
                user_id = payload.get("sub") # Assuming sub is user_id string or int
            except:
                pass
        
        # Ignore GET requests for static files or noise?
        # User wants "all usage".
        if request.url.path.startswith("/api"):
             self.log_activity(request, response, user_id, process_time)
             
        return response

    def log_activity(self, request, response, user_id, process_time):
        try:
            db = SessionLocal()
            log = ActivityLog(
                user_id=int(user_id) if user_id and str(user_id).isdigit() else None,
                action=f"{request.method} {request.url.path}",
                details=f"Status: {response.status_code} | Time: {process_time:.4f}s",
                ip_address=request.client.host,
                user_agent=request.headers.get("user-agent"),
                resource_type="api",
            )
            db.add(log)
            db.commit()
            db.close()
        except Exception as e:
            print(f"Logging failed: {e}")
