"""
Day Audit API — Business Day Open / Close (Night Audit)
Routes:
  GET  /day-audit/current         — Current open audit for branch
  GET  /day-audit/history         — Past audits (paginated)
  GET  /day-audit/checklist       — Pre-close checklist
  POST /day-audit/open            — Open a new business day
  POST /day-audit/close           — Close the day (runs night audit)
  GET  /day-audit/{id}            — Get audit by ID (full detail)
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional, List
from datetime import date, datetime, timezone
from pydantic import BaseModel

from app.utils.auth import get_db, get_current_user
from app.utils.branch_scope import get_branch_id
from app.models.user import User
from app.curd import day_audit as crud

router = APIRouter(prefix="/day-audit", tags=["Day Audit"])


# ── Pydantic Schemas ────────────────────────────────────────────────────────

class OpenDayRequest(BaseModel):
    business_date: date
    opening_cash_balance: float = 0.0
    opening_notes: str = ""


class CloseDayRequest(BaseModel):
    closing_cash_balance: float = 0.0
    closing_notes: str = ""


class DayAuditOut(BaseModel):
    id: int
    branch_id: int
    business_date: date
    status: str
    opened_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    opening_cash_balance: float = 0.0
    closing_cash_balance: float = 0.0
    opening_notes: Optional[str] = None
    closing_notes: Optional[str] = None
    total_room_revenue: float = 0.0
    total_food_revenue: float = 0.0
    total_service_revenue: float = 0.0
    total_gst_collected: float = 0.0
    total_payments_received: float = 0.0
    rooms_occupied: int = 0
    new_checkins: int = 0
    new_checkouts: int = 0
    audit_log: Optional[list] = None

    class Config:
        from_attributes = True


# ── Endpoints ───────────────────────────────────────────────────────────────

@router.get("/current", response_model=Optional[DayAuditOut])
def get_current_audit(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Return the currently open business day for this branch, or null if none."""
    return crud.get_current_open_audit(db, branch_id)


@router.get("/checklist")
def get_close_checklist(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Pre-close checklist: pending food, services, checkouts, in-house count."""
    return crud.get_preclose_checklist(db, branch_id)


@router.get("/history", response_model=List[DayAuditOut])
def get_audit_history(
    skip: int = 0,
    limit: int = 30,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Return past Day Audit records for this branch, newest first."""
    return crud.get_audit_history(db, branch_id, skip=skip, limit=limit)


@router.post("/open", response_model=DayAuditOut)
def open_business_day(
    body: OpenDayRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Open a new business day for this branch."""
    try:
        audit = crud.open_day(
            db,
            branch_id=branch_id,
            business_date=body.business_date,
            opened_by_id=current_user.id,
            opening_cash_balance=body.opening_cash_balance,
            opening_notes=body.opening_notes,
        )
        return audit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/close", response_model=DayAuditOut)
def close_business_day(
    body: CloseDayRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """
    Close the current business day and run the Night Audit routine:
    - Posts nightly room charges for all in-house bookings
    - Computes revenue totals
    - Locks the day
    """
    try:
        audit = crud.close_day(
            db,
            branch_id=branch_id,
            closed_by_id=current_user.id,
            closing_cash_balance=body.closing_cash_balance,
            closing_notes=body.closing_notes,
        )
        return audit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Night audit failed: {str(e)}")


@router.get("/{audit_id}", response_model=DayAuditOut)
def get_audit_detail(
    audit_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Get a specific audit by ID (must belong to this branch)."""
    from app.models.day_audit import DayAudit
    audit = db.query(DayAudit).filter(
        DayAudit.id == audit_id,
        DayAudit.branch_id == branch_id,
    ).first()
    if not audit:
        raise HTTPException(status_code=404, detail="Audit not found")
    return audit
