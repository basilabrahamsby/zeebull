#!/usr/bin/env python3
"""
Force import missing Aiosell/OTA bookings into PMS.

This script:
1. Connects to the local DB and checks which external_ids already exist
2. Calls the Aiosell API to fetch recent reservations
3. Re-sends any missing ones through the local webhook handler

Usage:
  python force_import_aiosell_bookings.py
"""
import os, sys, requests

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.booking import Booking
from app.api.channel_manager import _handle_new_booking
from app.utils.aiosell_config import is_aiosell_active

AIOSELL_BASE_URL = os.getenv("AIOSELL_BASE_URL", "https://live.aiosell.com")
AIOSELL_API_KEY  = os.getenv("AIOSELL_API_KEY", "")
PROPERTY_ID      = os.getenv("AIOSELL_PROPERTY_ID", "")
BRANCH_ID        = int(os.getenv("DEFAULT_BRANCH_ID", "1"))

def fetch_aiosell_reservations():
    """Fetch recent reservations from Aiosell API."""
    if not AIOSELL_API_KEY or not PROPERTY_ID:
        print("[WARN] AIOSELL_API_KEY or AIOSELL_PROPERTY_ID not set in env. Skipping remote fetch.")
        return []

    url = f"{AIOSELL_BASE_URL}/api/reservations"
    headers = {"Authorization": f"Bearer {AIOSELL_API_KEY}"}
    params  = {"property_id": PROPERTY_ID, "limit": 100}

    try:
        r = requests.get(url, headers=headers, params=params, timeout=15)
        r.raise_for_status()
        data = r.json()
        reservations = data if isinstance(data, list) else data.get("reservations", data.get("data", []))
        print(f"[AIOSELL] Fetched {len(reservations)} reservation(s) from Aiosell.")
        return reservations
    except Exception as e:
        print(f"[ERROR] Could not fetch reservations from Aiosell: {e}")
        return []

def main():
    db = SessionLocal()
    try:
        if not is_aiosell_active(db):
            print("[WARN] Aiosell is disabled in this environment. Aborting.")
            return

        # Get all external_ids already in the DB
        existing_ids = {r[0] for r in db.query(Booking.external_id).filter(Booking.external_id.isnot(None)).all()}
        print(f"[DB] Found {len(existing_ids)} existing OTA booking(s) in PMS.")

        reservations = fetch_aiosell_reservations()
        if not reservations:
            print("[INFO] No reservations fetched. Nothing to import.")
            return

        imported = 0
        skipped  = 0
        failed   = 0

        for res in reservations:
            res_id = str(res.get("bookingID") or res.get("bookingId") or "")
            if not res_id:
                print(f"[SKIP] Reservation missing bookingID: {res}")
                skipped += 1
                continue

            if res_id in existing_ids:
                print(f"[SKIP] Already in PMS: {res_id}")
                skipped += 1
                continue

            # Ensure the action field is set for the handler
            res.setdefault("action", "book")

            try:
                result = _handle_new_booking(res, db, BRANCH_ID)
                print(f"[IMPORT] Imported {res_id} -> {result}")
                existing_ids.add(res_id)
                imported += 1
            except Exception as e:
                print(f"[ERROR] Failed to import {res_id}: {e}")
                db.rollback()
                failed += 1

        print(f"\n=== DONE: Imported={imported}, Skipped={skipped}, Failed={failed} ===")

    finally:
        db.close()

if __name__ == "__main__":
    main()
