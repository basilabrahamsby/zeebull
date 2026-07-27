#!/usr/bin/env python3
"""
Test script to verify that online bookings (source: userend) respect online_inventory quota limits,
while offline bookings (source: Direct) bypass the quota limits.
"""
import os
import sys
import requests

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.room import RoomType
from app.models.user import User, Role
from app.utils.auth import create_access_token
from sqlalchemy import text
from datetime import date, timedelta

def run_test():
    db = SessionLocal()
    try:
        print("=== STARTING OTA QUOTA ENFORCEMENT TEST ===")
        
        # 1. Get first room type
        room_type = db.query(RoomType).first()
        if not room_type:
            print("ERROR: No RoomType found in the database.")
            return
            
        print(f"Using RoomType: {room_type.name} (ID: {room_type.id})")
        
        # 2. Get first branch ID
        branch_id = room_type.branch_id
        print(f"Branch ID: {branch_id}")
        
        # Save original online_inventory to restore later
        original_online_inv = room_type.online_inventory
        
        # Set online_inventory limit to 1
        room_type.online_inventory = 1
        db.commit()
        print(f"Set online_inventory to {room_type.online_inventory}")

        # 3. Authenticate as admin (to make requests if needed, although public guest booking is public)
        # We can use the public endpoint or authenticated endpoint.
        # Let's use the authenticated route for testing, but passing different source values.
        admin_role = db.query(Role).filter(Role.name == 'admin').first()
        admin_user = db.query(User).filter(User.role_id == admin_role.id).first() if admin_role else None
        
        if not admin_user:
            print("ERROR: Admin user not found.")
            return
            
        token = create_access_token(data={'user_id': admin_user.id, 'sub': admin_user.email})
        headers = {
            "Authorization": f"Bearer {token}",
            "X-Branch-Id": str(branch_id),
            "Content-Type": "application/json"
        }

        # Booking dates (overlapping)
        check_in = (date.today() + timedelta(days=10)).isoformat()
        check_out = (date.today() + timedelta(days=11)).isoformat()
        
        # First booking: Online Guest Booking (source = 'userend')
        # This fits within online_inventory = 1, so it should succeed.
        payload_1 = {
            "guest_name": "Online Test Guest 1",
            "guest_mobile": "1234567890",
            "guest_email": "guest1@test.com",
            "check_in": check_in,
            "check_out": check_out,
            "adults": 1,
            "children": 0,
            "room_type_id": room_type.id,
            "source": "userend",
            "num_rooms": 1,
            "branch_id": branch_id
        }
        
        print("\n[TEST 1] Creating first online booking (source = 'userend')...")
        url = "http://localhost:8011/api/bookings"
        res_1 = requests.post(url, json=payload_1, headers=headers)
        
        print(f"Response Status Code: {res_1.status_code}")
        assert res_1.status_code == 200, f"Expected 200, got {res_1.status_code}: {res_1.text}"
        booking_1_id = res_1.json()["id"]
        print(f"SUCCESS: First online booking created with ID {booking_1_id}")

        # Second booking: Overlapping Online Guest Booking (source = 'userend')
        # Since online_inventory limit is 1, and 1 is already booked, this should FAIL with 400 Bad Request.
        payload_2 = {
            "guest_name": "Online Test Guest 2",
            "guest_mobile": "9876543210",
            "guest_email": "guest2@test.com",
            "check_in": check_in,
            "check_out": check_out,
            "adults": 1,
            "children": 0,
            "room_type_id": room_type.id,
            "source": "userend",
            "num_rooms": 1,
            "branch_id": branch_id
        }
        
        print("\n[TEST 2] Attempting to create second online booking (exceeding OTA quota limit of 1)...")
        res_2 = requests.post(url, json=payload_2, headers=headers)
        
        print(f"Response Status Code: {res_2.status_code}")
        print(f"Response content: {res_2.text}")
        assert res_2.status_code == 400, f"Expected 400 Bad Request, got {res_2.status_code}"
        print("SUCCESS: Booking was rejected with 400 Bad Request as it exceeded OTA quota!")

        # Third booking: Overlapping Offline Admin Booking (source = 'Direct')
        # Offline/dashboard bookings bypass OTA quota, so this should SUCCEED.
        payload_3 = {
            "guest_name": "Offline Test Admin",
            "guest_mobile": "5555555555",
            "guest_email": "admin_direct@test.com",
            "check_in": check_in,
            "check_out": check_out,
            "adults": 1,
            "children": 0,
            "room_type_id": room_type.id,
            "source": "Direct",
            "num_rooms": 1,
            "branch_id": branch_id
        }
        
        print("\n[TEST 3] Creating offline booking (source = 'Direct') on overlapping dates...")
        res_3 = requests.post(url, json=payload_3, headers=headers)
        
        print(f"Response Status Code: {res_3.status_code}")
        assert res_3.status_code == 200, f"Expected 200 OK for offline booking, got {res_3.status_code}: {res_3.text}"
        booking_3_id = res_3.json()["id"]
        print(f"SUCCESS: Offline booking bypasses OTA quota and created with ID {booking_3_id} successfully!")

        print("\n=== ALL TESTS PASSED SUCCESSFULLY! ===")

    except Exception as e:
        print(f"\n!!! TEST FAILED: {e} !!!")
        import traceback
        traceback.print_exc()
    finally:
        # Clean up created bookings
        print("\nCleaning up bookings...")
        try:
            db.execute(text("DELETE FROM booking_rooms WHERE booking_id IN (SELECT id FROM bookings WHERE guest_name IN ('Online Test Guest 1', 'Offline Test Admin'))"))
            db.execute(text("DELETE FROM bookings WHERE guest_name IN ('Online Test Guest 1', 'Offline Test Admin')"))
            db.commit()
            print("Bookings cleaned up successfully.")
        except Exception as cleanup_err:
            print(f"Error cleaning up bookings: {cleanup_err}")
            db.rollback()

        # Restore original online_inventory
        try:
            room_type = db.query(RoomType).filter(RoomType.id == room_type.id).first()
            if room_type:
                room_type.online_inventory = original_online_inv
                db.commit()
                print(f"Restored original online_inventory to: {original_online_inv}")
        except Exception as restore_err:
            print(f"Error restoring RoomType: {restore_err}")
            db.rollback()
            
        db.close()

if __name__ == "__main__":
    run_test()
