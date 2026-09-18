from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request
from fastapi.responses import JSONResponse
from app.services import lock_service

class LockEnforcementMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # Always allow CORS preflight requests
        if request.method == "OPTIONS":
            return await call_next(request)

        path = request.url.path.lower()

        # Whitelist endpoints that must remain accessible during suspension
        whitelist_prefixes = [
            "/api/system-lock",      # Status check & unlock endpoints
            "/system-lock",
            "/api/public",           # Guest website / catalog browsing
            "/public",
            "/api/booking/public",   # Public guest reservations
            "/api/bookings/public",
            "/uploads",              # Static image uploads
            "/static",
            "/favicon.ico",
            "/docs",
            "/redoc",
            "/openapi.json"
        ]

        if any(path.startswith(prefix) for prefix in whitelist_prefixes):
            return await call_next(request)

        # Non-API routes (e.g. root static pages if served directly) pass through
        if not path.startswith("/api/"):
            return await call_next(request)

        # Check if system is suspended
        if lock_service.is_system_locked():
            lock_state = lock_service.get_lock_state()
            return JSONResponse(
                status_code=423,  # 423 Locked
                content={
                    "detail": lock_state.get("reason", "Administrative access suspended due to pending account settlement."),
                    "code": "SERVICE_SUSPENDED",
                    "state": lock_state
                },
                headers={
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "*",
                    "Access-Control-Allow-Headers": "*",
                    "X-Service-Suspended": "true"
                }
            )

        return await call_next(request)
