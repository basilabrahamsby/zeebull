#!/usr/bin/env python3
"""
TeqMates Hospitality Management - System Service Lock CLI
Use this tool to lock/unlock the admin service or generate activation keys.

Usage:
  python manage_lock.py status
  python manage_lock.py lock [--reason "Reason for suspension"] [--phone "+91 9400000000"] [--email "billing@teqmates.com"]
  python manage_lock.py unlock
  python manage_lock.py key --ref ZEB-YYYY-XXXX
"""

import sys
import os
import argparse
from pathlib import Path

# Add current directory to path so app modules are discoverable
current_dir = Path(__file__).resolve().parent
sys.path.insert(0, str(current_dir))

from dotenv import load_dotenv
load_dotenv(dotenv_path=current_dir / ".env", override=True)

from app.services import lock_service
from app.database import SessionLocal

def cmd_status(args):
    db = SessionLocal()
    try:
        state = lock_service.get_lock_state(db=db, force_refresh=True)
        print("\n=======================================================")
        print("          TEQMATES SYSTEM SUSPENSION STATUS            ")
        print("=======================================================")
        is_locked = state.get("is_locked", False)
        status_text = "LOCKED / SUSPENDED" if is_locked else "ACTIVE (NORMAL)"
        print(f"Status:          [{status_text}]")
        if is_locked:
            ref = state.get("reference_code", "")
            print(f"Lock Reference:  {ref}")
            print(f"Reason:          {state.get('reason', '')}")
            print(f"Locked At:       {state.get('locked_at', '')}")
            print(f"Support Phone:   {state.get('support_phone', '')}")
            print(f"Support Email:   {state.get('support_email', '')}")
            key = lock_service.generate_key_from_ref(ref)
            print(f"Activation Key:  {key}")
        print("=======================================================\n")
    finally:
        db.close()

def cmd_lock(args):
    db = SessionLocal()
    try:
        reason = args.reason or "Administrative access suspended due to pending account settlement."
        state = lock_service.lock_system(
            reason=reason,
            support_phone=args.phone,
            support_email=args.email,
            db=db
        )
        ref = state.get("reference_code", "")
        key = lock_service.generate_key_from_ref(ref)
        print("\n[SUCCESS] System has been permanently LOCKED.")
        print(f"Reference Code: {ref}")
        print(f"Activation Key: {key}")
        print("Admin dashboard & staff APIs are now blocked with HTTP 423 Locked.")
        print("Public guest booking portal remains open.\n")
    finally:
        db.close()

def cmd_unlock(args):
    db = SessionLocal()
    try:
        lock_service.unlock_system(db=db)
        print("\n[SUCCESS] System has been permanently UNLOCKED.")
        print("Admin dashboard & staff APIs have been fully restored.\n")
    finally:
        db.close()

def cmd_key(args):
    ref = args.ref.strip().upper()
    if not ref:
        print("[ERROR] Please provide --ref reference code.")
        sys.exit(1)
    key = lock_service.generate_key_from_ref(ref)
    print("\n=======================================================")
    print(f"Reference Code:  {ref}")
    print(f"Activation Key:  {key}")
    print("=======================================================\n")

def main():
    parser = argparse.ArgumentParser(description="TeqMates System Service Lock CLI")
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # status
    subparsers.add_parser("status", help="Display current lock status")

    # lock
    p_lock = subparsers.add_parser("lock", help="Place system in permanent administrative suspension")
    p_lock.add_argument("--reason", type=str, default=None, help="Suspension reason")
    p_lock.add_argument("--phone", type=str, default=None, help="Support phone number")
    p_lock.add_argument("--email", type=str, default=None, help="Support email address")

    # unlock
    subparsers.add_parser("unlock", help="Permanently unlock the system")

    # key
    p_key = subparsers.add_parser("key", help="Generate activation key for a given reference code")
    p_key.add_argument("--ref", type=str, required=True, help="Reference code (e.g. ZEB-2026-A1B2)")

    args = parser.parse_args()
    if args.command == "status":
        cmd_status(args)
    elif args.command == "lock":
        cmd_lock(args)
    elif args.command == "unlock":
        cmd_unlock(args)
    elif args.command == "key":
        cmd_key(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
