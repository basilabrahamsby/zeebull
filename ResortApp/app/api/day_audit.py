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
    opening_account_balance: float = 0.0
    opening_notes: str = ""


class CloseDayRequest(BaseModel):
    closing_cash_balance: float = 0.0
    closing_account_balance: float = 0.0
    system_expected_cash: float = 0.0
    system_expected_account: float = 0.0
    override_reason: str = ""
    closing_notes: str = ""


class DayAuditOut(BaseModel):
    id: int
    branch_id: int
    business_date: date
    status: str
    opened_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    opening_cash_balance: float = 0.0
    opening_account_balance: float = 0.0
    closing_cash_balance: float = 0.0
    closing_account_balance: float = 0.0
    system_expected_cash: float = 0.0
    system_expected_account: float = 0.0
    override_reason: Optional[str] = None
    opening_notes: Optional[str] = None
    closing_notes: Optional[str] = None
    total_room_revenue: float = 0.0
    total_food_revenue: float = 0.0
    total_service_revenue: float = 0.0
    total_gst_collected: float = 0.0
    total_payments_received: float = 0.0
    total_expenses: float = 0.0
    total_purchases: float = 0.0
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
    if branch_id is None:
        return None
    return crud.get_current_open_audit(db, branch_id)


@router.get("/checklist")
def get_close_checklist(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Pre-close checklist: pending food, services, checkouts, in-house count."""
    if branch_id is None:
        raise HTTPException(status_code=400, detail="Please select a specific branch.")
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
    if branch_id is None:
        return []
    return crud.get_audit_history(db, branch_id, skip=skip, limit=limit)


@router.post("/open", response_model=DayAuditOut)
def open_business_day(
    body: OpenDayRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Open a new business day for this branch."""
    if branch_id is None:
        raise HTTPException(status_code=400, detail="Please select a specific branch before opening a business day.")
    try:
        audit = crud.open_day(
            db,
            branch_id=branch_id,
            business_date=body.business_date,
            opened_by_id=current_user.id,
            opening_cash_balance=body.opening_cash_balance,
            opening_account_balance=body.opening_account_balance,
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
    if branch_id is None:
        raise HTTPException(status_code=400, detail="Please select a specific branch before closing the day.")
    try:
        audit = crud.close_day(
            db,
            branch_id=branch_id,
            closed_by_id=current_user.id,
            closing_cash_balance=body.closing_cash_balance,
            closing_account_balance=body.closing_account_balance,
            system_expected_cash=body.system_expected_cash,
            system_expected_account=body.system_expected_account,
            override_reason=body.override_reason,
            closing_notes=body.closing_notes,
        )
        return audit
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Night audit failed: {str(e)}")


@router.get("/transactions")
def get_day_transactions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Fetch all accounting transactions for the current open business day."""
    if branch_id is None:
        return []
    audit = crud.get_current_open_audit(db, branch_id)
    if not audit:
        return []
    
    # We fetch from JournalEntry as it's the most comprehensive
    from app.models.account import JournalEntry, JournalEntryLine, AccountLedger
    from sqlalchemy.orm import joinedload
    
    entries = (
        db.query(JournalEntry)
        .options(
            joinedload(JournalEntry.lines).joinedload(JournalEntryLine.debit_ledger),
            joinedload(JournalEntry.lines).joinedload(JournalEntryLine.credit_ledger)
        )
        .filter(
            JournalEntry.branch_id == branch_id,
            JournalEntry.entry_date >= audit.opened_at,
        )
        .order_by(JournalEntry.entry_date.desc())
        .all()
    )
    
    result = []
    for entry in entries:
        result.append({
            "id": entry.id,
            "entry_number": entry.entry_number,
            "entry_date": entry.entry_date,
            "reference_type": entry.reference_type,
            "reference_id": entry.reference_id,
            "description": entry.description,
            "total_amount": entry.total_amount,
            "lines": [
                {
                    "debit": line.debit_ledger.name if line.debit_ledger else None,
                    "credit": line.credit_ledger.name if line.credit_ledger else None,
                    "amount": line.amount,
                    "description": line.description
                } for line in entry.lines
            ]
        })
    return result


@router.get("/{audit_id}/transactions")
def get_historical_transactions(
    audit_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Fetch all accounting transactions for a specific historical business day."""
    if branch_id is None:
        raise HTTPException(status_code=400, detail="Please select a specific branch.")
    
    from app.models.day_audit import DayAudit
    audit = db.query(DayAudit).filter(
        DayAudit.id == audit_id,
        DayAudit.branch_id == branch_id,
    ).first()
    
    if not audit:
        raise HTTPException(status_code=404, detail="Audit not found")
    
    # We fetch from JournalEntry between opened_at and closed_at
    from app.models.account import JournalEntry, JournalEntryLine, AccountLedger
    from sqlalchemy.orm import joinedload
    
    query = db.query(JournalEntry).options(
        joinedload(JournalEntry.lines).joinedload(JournalEntryLine.debit_ledger),
        joinedload(JournalEntry.lines).joinedload(JournalEntryLine.credit_ledger)
    ).filter(JournalEntry.branch_id == branch_id)

    if audit.status == "open":
        query = query.filter(JournalEntry.entry_date >= audit.opened_at)
    else:
        # For closed audits, we need the window
        # closed_at might be null if it crashed, but usually it's there
        start = audit.opened_at
        end = audit.closed_at or datetime.now(timezone.utc)
        query = query.filter(JournalEntry.entry_date >= start, JournalEntry.entry_date <= end)
    
    entries = query.order_by(JournalEntry.entry_date.desc()).all()
    
    result = []
    for entry in entries:
        result.append({
            "id": entry.id,
            "entry_number": entry.entry_number,
            "entry_date": entry.entry_date,
            "reference_type": entry.reference_type,
            "reference_id": entry.reference_id,
            "description": entry.description,
            "total_amount": entry.total_amount,
            "lines": [
                {
                    "debit": line.debit_ledger.name if line.debit_ledger else None,
                    "credit": line.credit_ledger.name if line.credit_ledger else None,
                    "amount": line.amount,
                    "description": line.description
                } for line in entry.lines
            ]
        })
    return result


@router.get("/{audit_id}", response_model=DayAuditOut)
def get_audit_detail(
    audit_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    branch_id: int = Depends(get_branch_id),
):
    """Get a specific audit by ID (must belong to this branch)."""
    if branch_id is None:
        raise HTTPException(status_code=400, detail="Please select a specific branch.")
    
    audit = crud.get_audit_by_id(db, audit_id, branch_id)
    
    if not audit:
        raise HTTPException(status_code=404, detail="Audit not found")
    return audit
