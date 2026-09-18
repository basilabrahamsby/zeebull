import os
from fastapi import APIRouter, HTTPException, Depends, Header, status
from pydantic import BaseModel
from typing import Optional, Dict, Any
from sqlalchemy.orm import Session

from app.utils.auth import get_db
from app.services import lock_service

router = APIRouter(prefix="/system-lock", tags=["System Service Suspension Lock"])

class UnlockRequest(BaseModel):
    activation_key: str

class LockRequest(BaseModel):
    reason: Optional[str] = None
    support_phone: Optional[str] = None
    support_email: Optional[str] = None

@router.get("/status")
def get_lock_status(db: Session = Depends(get_db)) -> Dict[str, Any]:
    """Public endpoint to check if the system is locked, and retrieve support/reference info."""
    return lock_service.get_lock_state(db=db, force_refresh=True)

@router.post("/unlock")
def unlock_with_key(payload: UnlockRequest, db: Session = Depends(get_db)) -> Dict[str, Any]:
    """Verify cryptographic activation key and permanently unlock the system."""
    key = payload.activation_key.strip()
    if not key:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Activation key cannot be empty.")

    success, message = lock_service.verify_and_unlock(key, db=db)
    if not success:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=message)

    return {
        "success": True,
        "message": message,
        "status": lock_service.get_lock_state(db=db, force_refresh=True)
    }

@router.post("/lock")
def trigger_lock(
    payload: LockRequest,
    x_master_lock_key: Optional[str] = Header(None),
    db: Session = Depends(get_db)
) -> Dict[str, Any]:
    """
    Triggers administrative suspension lock.
    Requires server-level master signing key for authorization.
    """
    configured_secret = lock_service.SYSTEM_LOCK_SECRET
    if not x_master_lock_key or x_master_lock_key != configured_secret:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Unauthorized: Valid X-Master-Lock-Key header required to trigger lock."
        )

    state = lock_service.lock_system(
        reason=payload.reason,
        support_phone=payload.support_phone,
        support_email=payload.support_email,
        db=db
    )
    return {
        "success": True,
        "message": "System has been placed into administrative suspension.",
        "state": state
    }
