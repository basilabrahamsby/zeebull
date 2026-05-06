"""
Day Audit CRUD operations.
Manages business day lifecycle: open, close, night audit routine.
"""
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from datetime import date, datetime, timezone
from typing import Optional, List, Dict, Any

from app.models.day_audit import DayAudit, NightCharge
from app.models.booking import Booking, BookingRoom
from app.models.room import Room


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def get_current_open_audit(db: Session, branch_id: int) -> Optional[DayAudit]:
    """Return the currently open DayAudit for a branch, or None."""
    audit = (
        db.query(DayAudit)
        .filter(DayAudit.branch_id == branch_id, DayAudit.status == "open")
        .first()
    )
    if audit:
        # Calculate live checkins and checkouts since day was opened
        nc_in = (
            db.query(func.count(Booking.id))
            .filter(
                Booking.branch_id == branch_id,
                Booking.checked_in_at >= audit.opened_at,
            )
            .scalar()
        ) or 0
        
        nc_out = (
            db.query(func.count(Booking.id))
            .filter(
                Booking.branch_id == branch_id,
                Booking.checked_out_at >= audit.opened_at,
            )
            .scalar()
        ) or 0
        
        audit.new_checkins = nc_in
        audit.new_checkouts = nc_out

        # Calculate live revenues since day was opened
        from app.models.checkout import Checkout, CheckoutPayment
        from app.models.foodorder import FoodOrder
        from app.models.service import AssignedService
        from app.models.service import Service as ServiceModel
        from sqlalchemy.sql import case

        checkouts = (
            db.query(Checkout)
            .filter(
                Checkout.branch_id == branch_id,
                Checkout.created_at >= audit.opened_at,
            )
            .all()
        )
        checkout_room_total = sum(float(c.room_total or 0.0) for c in checkouts)
        checkout_food_total = sum(float(c.food_total or 0.0) for c in checkouts)
        checkout_service_total = sum(float(c.service_total or 0.0) for c in checkouts)
        checkout_tax_total = sum(float(c.tax_amount or 0.0) for c in checkouts)

        food_revenue = (
            db.query(func.coalesce(func.sum(FoodOrder.total_with_gst), 0))
            .filter(
                FoodOrder.branch_id == branch_id,
                FoodOrder.created_at >= audit.opened_at,
            )
            .scalar()
        ) or 0.0

        service_revenue = (
            db.query(func.coalesce(func.sum(
                case(
                    (AssignedService.override_charges != None, AssignedService.override_charges),
                    else_=ServiceModel.charges
                )
            ), 0))
            .join(ServiceModel, AssignedService.service_id == ServiceModel.id)
            .filter(
                AssignedService.branch_id == branch_id,
                AssignedService.assigned_at >= audit.opened_at,
            )
            .scalar()
        ) or 0.0

        checkout_payments = (
            db.query(CheckoutPayment)
            .filter(
                CheckoutPayment.branch_id == branch_id,
                CheckoutPayment.created_at >= audit.opened_at,
            )
            .all()
        )
        payments_received = sum(float(p.amount or 0.0) for p in checkout_payments)

        audit.total_room_revenue = round(checkout_room_total, 2)
        audit.total_food_revenue = round(float(food_revenue) + checkout_food_total, 2)
        audit.total_service_revenue = round(float(service_revenue) + checkout_service_total, 2)
        audit.total_gst_collected = round(checkout_tax_total, 2)
        audit.total_payments_received = round(payments_received, 2)
        
    return audit


def get_audit_by_date(db: Session, branch_id: int, business_date: date) -> Optional[DayAudit]:
    return (
        db.query(DayAudit)
        .filter(DayAudit.branch_id == branch_id, DayAudit.business_date == business_date)
        .first()
    )


def get_audit_history(db: Session, branch_id: int, skip: int = 0, limit: int = 30) -> List[DayAudit]:
    return (
        db.query(DayAudit)
        .filter(DayAudit.branch_id == branch_id)
        .order_by(DayAudit.business_date.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )


# ---------------------------------------------------------------------------
# Day Open
# ---------------------------------------------------------------------------

def open_day(
    db: Session,
    branch_id: int,
    business_date: date,
    opened_by_id: int,
    opening_cash_balance: float = 0.0,
    opening_notes: str = "",
) -> DayAudit:
    """
    Open a new business day for the branch.
    Raises ValueError if a day is already open or the date already has a record.
    """
    # Guard: no other open day
    existing_open = get_current_open_audit(db, branch_id)
    if existing_open:
        raise ValueError(
            f"Business day {existing_open.business_date} is already open. "
            "Close it before opening a new day."
        )

    # Guard: date not already audited
    existing_date = get_audit_by_date(db, branch_id, business_date)
    if existing_date:
        raise ValueError(f"Business date {business_date} already has an audit record.")

    audit = DayAudit(
        branch_id=branch_id,
        business_date=business_date,
        status="open",
        opened_at=datetime.now(timezone.utc),
        opened_by_id=opened_by_id,
        opening_cash_balance=opening_cash_balance,
        opening_notes=opening_notes,
        audit_log=[{"step": "Day Opened", "status": "done", "ts": datetime.now(timezone.utc).isoformat()}],
    )
    db.add(audit)
    db.commit()
    db.refresh(audit)
    return audit


# ---------------------------------------------------------------------------
# Day Close — Night Audit Routine
# ---------------------------------------------------------------------------

def close_day(
    db: Session,
    branch_id: int,
    closed_by_id: int,
    closing_cash_balance: float = 0.0,
    closing_notes: str = "",
) -> DayAudit:
    """
    Run the night audit routine and close the business day.
    Steps:
      1. Validate open day exists
      2. Post nightly room charges for all in-house bookings
      3. Compute revenue totals
      4. Mark audit as closed
    """
    audit = get_current_open_audit(db, branch_id)
    if not audit:
        raise ValueError("No open business day found. Open a day first.")

    audit.status = "closing"
    db.commit()

    log: List[Dict[str, Any]] = list(audit.audit_log or [])

    # ── Step 1: Find all in-house bookings for this branch ─────────────────
    in_house_bookings = (
        db.query(Booking)
        .filter(
            Booking.branch_id == branch_id,
            Booking.status == "checked_in",
        )
        .all()
    )
    log.append({
        "step": "Found in-house bookings",
        "count": len(in_house_bookings),
        "status": "done",
        "ts": datetime.now(timezone.utc).isoformat(),
    })

    # ── Step 2: Post nightly room charges ──────────────────────────────────
    from app.utils.settings_helpers import get_gst_settings

    gst_settings = get_gst_settings(db, branch_id)
    total_room_rev = 0.0
    total_gst = 0.0
    posted_count = 0

    for booking in in_house_bookings:
        # Skip if already posted for this business_date
        already_posted = (
            db.query(NightCharge)
            .filter(
                NightCharge.booking_id == booking.id,
                NightCharge.business_date == audit.business_date,
                NightCharge.is_reversed == False,
            )
            .first()
        )
        if already_posted:
            continue

        room_rate = float(booking.room_rate or 0.0)

        # Determine GST slab
        if not gst_settings.get("gst_enabled"):
            gst_rate_pct = 0.0
        elif gst_settings.get("gst_room_type") == "MANUAL":
            gst_rate_pct = float(gst_settings.get("room_gst_rate", 0))
        else:
            # Slab-based
            r1 = float(gst_settings.get("gst_slab_rate_1", 5))
            r2 = float(gst_settings.get("gst_slab_rate_2", 12))
            r3 = float(gst_settings.get("gst_slab_rate_3", 18))
            if room_rate < 5000:
                gst_rate_pct = r1
            elif room_rate < 7500:
                gst_rate_pct = r2
            else:
                gst_rate_pct = r3

        gst_amount = round(room_rate * gst_rate_pct / 100, 2)
        total_charge = round(room_rate + gst_amount, 2)

        night_charge = NightCharge(
            day_audit_id=audit.id,
            booking_id=booking.id,
            branch_id=branch_id,
            business_date=audit.business_date,
            room_charge=room_rate,
            gst_rate_pct=gst_rate_pct,
            gst_amount=gst_amount,
            total_charge=total_charge,
        )
        db.add(night_charge)
        total_room_rev += room_rate
        total_gst += gst_amount
        posted_count += 1

    db.flush()
    log.append({
        "step": "Night room charges posted",
        "posted": posted_count,
        "total_room_revenue": round(total_room_rev, 2),
        "total_gst": round(total_gst, 2),
        "status": "done",
        "ts": datetime.now(timezone.utc).isoformat(),
    })

    # ── Step 3: Compute food & service revenue from this business_date ─────
    from app.models.foodorder import FoodOrder
    from app.models.service import AssignedService

    food_revenue = (
        db.query(func.coalesce(func.sum(FoodOrder.total_with_gst), 0))
        .filter(
            FoodOrder.branch_id == branch_id,
            func.date(FoodOrder.created_at) == audit.business_date,
        )
        .scalar()
    ) or 0.0

    from sqlalchemy.sql import case
    from app.models.service import Service as ServiceModel

    service_revenue = (
        db.query(func.coalesce(func.sum(
            case(
                (AssignedService.override_charges != None, AssignedService.override_charges),
                else_=ServiceModel.charges
            )
        ), 0))
        .join(ServiceModel, AssignedService.service_id == ServiceModel.id)
        .filter(
            AssignedService.branch_id == branch_id,
            func.date(AssignedService.assigned_at) == audit.business_date,
        )
        .scalar()
    ) or 0.0

    log.append({
        "step": "Revenue totals computed",
        "food_revenue": round(float(food_revenue), 2),
        "service_revenue": round(float(service_revenue), 2),
        "status": "done",
        "ts": datetime.now(timezone.utc).isoformat(),
    })

    # ── Step 4: Count check-ins / check-outs today ─────────────────────────
    new_checkins = (
        db.query(func.count(Booking.id))
        .filter(
            Booking.branch_id == branch_id,
            Booking.checked_in_at >= audit.opened_at,
        )
        .scalar()
    ) or 0

    new_checkouts = (
        db.query(func.count(Booking.id))
        .filter(
            Booking.branch_id == branch_id,
            Booking.checked_out_at >= audit.opened_at,
        )
        .scalar()
    ) or 0

    log.append({
        "step": "Check-in/out counts",
        "checkins": new_checkins,
        "checkouts": new_checkouts,
        "status": "done",
        "ts": datetime.now(timezone.utc).isoformat(),
    })

    # ── Step 5: Finalize audit record ──────────────────────────────────────
    log.append({
        "step": "Day Closed",
        "status": "done",
        "ts": datetime.now(timezone.utc).isoformat(),
    })

    # ── Step 5: Finalize audit record including checkout totals ────────────
    from app.models.checkout import Checkout, CheckoutPayment

    checkouts = (
        db.query(Checkout)
        .filter(
            Checkout.branch_id == branch_id,
            Checkout.created_at >= audit.opened_at,
        )
        .all()
    )
    checkout_room_total = sum(float(c.room_total or 0.0) for c in checkouts)
    checkout_food_total = sum(float(c.food_total or 0.0) for c in checkouts)
    checkout_service_total = sum(float(c.service_total or 0.0) for c in checkouts)
    checkout_tax_total = sum(float(c.tax_amount or 0.0) for c in checkouts)

    checkout_payments = (
        db.query(CheckoutPayment)
        .filter(
            CheckoutPayment.branch_id == branch_id,
            CheckoutPayment.created_at >= audit.opened_at,
        )
        .all()
    )
    payments_received = sum(float(p.amount or 0.0) for p in checkout_payments)

    audit.status = "closed"
    audit.closed_at = datetime.now(timezone.utc)
    audit.closed_by_id = closed_by_id
    audit.closing_cash_balance = closing_cash_balance
    audit.closing_notes = closing_notes
    audit.total_room_revenue = round(total_room_rev + checkout_room_total, 2)
    audit.total_food_revenue = round(float(food_revenue) + checkout_food_total, 2)
    audit.total_service_revenue = round(float(service_revenue) + checkout_service_total, 2)
    audit.total_gst_collected = round(total_gst + checkout_tax_total, 2)
    audit.total_payments_received = round(payments_received, 2)
    audit.rooms_occupied = len(in_house_bookings)
    audit.new_checkins = new_checkins
    audit.new_checkouts = new_checkouts
    audit.audit_log = log

    db.commit()
    db.refresh(audit)
    return audit


# ---------------------------------------------------------------------------
# Pre-close checklist
# ---------------------------------------------------------------------------

def get_preclose_checklist(db: Session, branch_id: int) -> Dict[str, Any]:
    """
    Returns a checklist the front-end displays before Day Close.
    Warns staff of any pending items that should be resolved first.
    """
    from app.models.foodorder import FoodOrder
    from app.models.service import AssignedService
    from app.models.checkout import CheckoutRequest

    audit = get_current_open_audit(db, branch_id)
    business_date = audit.business_date if audit else date.today()

    # Pending food orders (not served/cancelled)
    open_food = (
        db.query(func.count(FoodOrder.id))
        .filter(
            FoodOrder.branch_id == branch_id,
            FoodOrder.status.notin_(["served", "delivered", "cancelled"]),
        )
        .scalar()
    ) or 0

    # Pending service requests
    open_services = (
        db.query(func.count(AssignedService.id))
        .filter(
            AssignedService.branch_id == branch_id,
            AssignedService.status.notin_(["completed", "cancelled"]),
        )
        .scalar()
    ) or 0

    # Pending checkout requests
    pending_checkouts = (
        db.query(func.count(CheckoutRequest.id))
        .filter(
            CheckoutRequest.branch_id == branch_id,
            CheckoutRequest.status.notin_(["completed", "cancelled"]),
        )
        .scalar()
    ) or 0

    # In-house count
    in_house = (
        db.query(func.count(Booking.id))
        .filter(Booking.branch_id == branch_id, Booking.status == "checked_in")
        .scalar()
    ) or 0

    items = [
        {"key": "food_orders", "label": "Open Food Orders", "count": open_food, "ok": open_food == 0},
        {"key": "services", "label": "Pending Service Requests", "count": open_services, "ok": open_services == 0},
        {"key": "checkouts", "label": "Pending Checkouts", "count": pending_checkouts, "ok": pending_checkouts == 0},
        {"key": "in_house", "label": "In-house Guests (will be charged tonight)", "count": in_house, "ok": True},
    ]

    return {
        "business_date": str(business_date),
        "can_close": open_food == 0 and pending_checkouts == 0,
        "warnings": [i for i in items if not i["ok"]],
        "checklist": items,
    }
