import os
import hmac
import hashlib
import time
import random
import string
from datetime import datetime
from typing import Dict, Any, Tuple, Optional
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.settings import SystemSetting

DEFAULT_MASTER_SECRET = "TEQMATES_ZEEBULL_MASTER_LOCK_SECRET_2026#!"
SYSTEM_LOCK_SECRET = os.getenv("SYSTEM_LOCK_SECRET", DEFAULT_MASTER_SECRET)

# In-memory cache to avoid database hit on every HTTP request
_lock_cache = {
    "is_locked": False,
    "data": None,
    "last_checked": 0.0,
    "ttl_seconds": 5.0
}

def invalidate_lock_cache():
    global _lock_cache
    _lock_cache["last_checked"] = 0.0

def normalize_key_string(key_str: str) -> str:
    """Removes hyphens, spaces, and converts to uppercase."""
    return "".join(c for c in key_str.upper() if c.isalnum())

def format_activation_key(raw_hex_16: str) -> str:
    """Formats 16 alphanumeric characters into ACT-XXXX-XXXX-XXXX-XXXX."""
    clean = raw_hex_16.upper()
    return f"ACT-{clean[0:4]}-{clean[4:8]}-{clean[8:12]}-{clean[12:16]}"

def generate_key_from_ref(reference_code: str, secret: Optional[str] = None) -> str:
    """
    Computes a deterministic cryptographic HMAC-SHA256 activation key from a reference code.
    Format: ACT-XXXX-XXXX-XXXX-XXXX
    """
    signing_secret = secret or SYSTEM_LOCK_SECRET
    norm_ref = reference_code.strip().upper()
    digest = hmac.new(
        signing_secret.encode("utf-8"),
        norm_ref.encode("utf-8"),
        hashlib.sha256
    ).hexdigest()
    raw_16 = digest[:16].upper()
    return format_activation_key(raw_16)

def generate_reference_code() -> str:
    """Generates a human-friendly unique reference code: ZEB-YYYY-XXXX."""
    year = datetime.utcnow().strftime("%Y")
    rand_chars = "".join(random.choices(string.ascii_uppercase + string.digits, k=4))
    return f"ZEB-{year}-{rand_chars}"

def _get_setting_value(db: Session, key: str, default: str = "") -> str:
    record = db.query(SystemSetting).filter(
        SystemSetting.key == key,
        SystemSetting.branch_id == None
    ).first()
    return record.value if (record and record.value is not None) else default

def _set_setting_value(db: Session, key: str, value: str, description: str = ""):
    record = db.query(SystemSetting).filter(
        SystemSetting.key == key,
        SystemSetting.branch_id == None
    ).first()
    if record:
        record.value = value
        if description:
            record.description = description
    else:
        record = SystemSetting(
            key=key,
            value=value,
            description=description,
            branch_id=None
        )
        db.add(record)

def get_lock_state(db: Optional[Session] = None, force_refresh: bool = False) -> Dict[str, Any]:
    """Returns current system lock details, with cached reads."""
    global _lock_cache
    now = time.time()
    if not force_refresh and (now - _lock_cache["last_checked"]) < _lock_cache["ttl_seconds"]:
        if _lock_cache["data"] is not None:
            return _lock_cache["data"]

    close_session = False
    if db is None:
        db = SessionLocal()
        close_session = True

    try:
        is_locked_str = _get_setting_value(db, "service_suspended_status", "false").lower()
        is_locked = is_locked_str in ("true", "1", "yes")

        ref_code = _get_setting_value(db, "service_suspended_ref", "")
        reason = _get_setting_value(
            db,
            "service_suspended_reason",
            "Administrative services suspended due to pending account settlement."
        )
        locked_at = _get_setting_value(db, "service_suspended_at", "")
        support_phone = _get_setting_value(db, "service_suspended_support_phone", "+91 94000 00000")
        support_email = _get_setting_value(db, "service_suspended_support_email", "billing@teqmates.com")

        data = {
            "is_locked": is_locked,
            "reference_code": ref_code,
            "reason": reason,
            "locked_at": locked_at,
            "support_phone": support_phone,
            "support_email": support_email,
        }

        _lock_cache["is_locked"] = is_locked
        _lock_cache["data"] = data
        _lock_cache["last_checked"] = now
        return data
    finally:
        if close_session:
            db.close()

def is_system_locked() -> bool:
    """Fast lock check used by middleware."""
    state = get_lock_state()
    return state.get("is_locked", False)

def lock_system(reason: Optional[str] = None, support_phone: Optional[str] = None, support_email: Optional[str] = None, db: Optional[Session] = None) -> Dict[str, Any]:
    """Permanently locks the system until unlocked by activation key."""
    close_session = False
    if db is None:
        db = SessionLocal()
        close_session = True

    try:
        ref_code = generate_reference_code()
        lock_reason = reason or "Administrative services temporarily suspended due to pending account settlement."
        timestamp = datetime.utcnow().isoformat()

        _set_setting_value(db, "service_suspended_status", "true", "System non-payment suspension status")
        _set_setting_value(db, "service_suspended_ref", ref_code, "Unique system lock reference code")
        _set_setting_value(db, "service_suspended_reason", lock_reason, "Reason for suspension")
        _set_setting_value(db, "service_suspended_at", timestamp, "Suspension timestamp")
        if support_phone:
            _set_setting_value(db, "service_suspended_support_phone", support_phone)
        if support_email:
            _set_setting_value(db, "service_suspended_support_email", support_email)

        db.commit()
        invalidate_lock_cache()
        return get_lock_state(db=db, force_refresh=True)
    finally:
        if close_session:
            db.close()

def unlock_system(db: Optional[Session] = None) -> Dict[str, Any]:
    """Permanently removes the system suspension lock."""
    close_session = False
    if db is None:
        db = SessionLocal()
        close_session = True

    try:
        _set_setting_value(db, "service_suspended_status", "false", "System non-payment suspension status")
        db.commit()
        invalidate_lock_cache()
        return {"success": True, "message": "System has been permanently unlocked."}
    finally:
        if close_session:
            db.close()

def verify_and_unlock(activation_key: str, db: Optional[Session] = None) -> Tuple[bool, str]:
    """
    Validates the supplied activation key against the active lock reference.
    Permanently unlocks on successful match.
    """
    state = get_lock_state(db=db, force_refresh=True)
    if not state.get("is_locked", False):
        return True, "System is not currently locked."

    active_ref = state.get("reference_code", "").strip()
    if not active_ref:
        return False, "No active lock reference code found."

    expected_key = generate_key_from_ref(active_ref)

    # Normalize both for safe comparison
    norm_provided = normalize_key_string(activation_key)
    norm_expected = normalize_key_string(expected_key)

    # Optional master bypass key in environment
    master_key = os.getenv("SYSTEM_LOCK_MASTER_KEY", "")
    norm_master = normalize_key_string(master_key) if master_key else ""

    is_valid = hmac.compare_digest(norm_provided, norm_expected)
    if not is_valid and norm_master and hmac.compare_digest(norm_provided, norm_master):
        is_valid = True

    if is_valid:
        unlock_system(db=db)
        return True, "Activation key verified successfully! Service is fully restored."
    else:
        return False, "Invalid activation key. Please check the key or contact billing support."
