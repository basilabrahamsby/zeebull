import os
import sys
import base64
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Import FastAPI app and database components
from main import app
from app.database import SQLALCHEMY_DATABASE_URL, SessionLocal
from app.models.booking import Booking

print("Setting up FastAPI TestClient...")
client = TestClient(app)

# Helper for Basic Auth header
def get_auth_headers(username="sandboxpms", password="sandboxpms"):
    credentials = f"{username}:{password}"
    encoded = base64.b64encode(credentials.encode()).decode()
    return {"Authorization": f"Basic {encoded}"}

# Mock Payload for new booking
mock_payload = {
    "bookingID": "TEST-DUP-123",
    "action": "book",
    "channel": "Booking.com",
    "checkin": "2026-06-01",
    "checkout": "2026-06-05",
    "guest": {
        "firstName": "Test",
        "lastName": "DuplicateGuest",
        "email": "testdup@example.com",
        "phone": "+1234567890"
    },
    "rooms": [
        {
            "roomCode": "deluxe",
            "sellingPrice": "120.00",
            "occupancy": {
                "adults": 2,
                "children": 0
            }
        }
    ],
    "totalAmount": "480.00",
    "notes": "Testing duplicate prevention webhook handler"
}

db = SessionLocal()

try:
    print("Pre-test cleanup: checking if 'TEST-DUP-123' exists...")
    # Delete any existing test bookings with our test ID
    db.query(Booking).filter(Booking.external_id == "TEST-DUP-123").delete()
    db.commit()
    
    # 1. Send the first webhook call (New Booking)
    print("\n--- TEST STEP 1: Sending first 'book' webhook request ---")
    headers = get_auth_headers()
    response_1 = client.post("/api/channel-manager/webhook", json=mock_payload, headers=headers)
    
    assert response_1.status_code == 200, f"Expected 200, got {response_1.status_code}"
    res_data_1 = response_1.json()
    print("Response 1:", res_data_1)
    assert res_data_1.get("success") is True, "First booking should succeed"
    assert "booking_id" in res_data_1, "Response should contain booking_id"
    
    booking_id = res_data_1["booking_id"]
    display_id = res_data_1["display_id"]
    print(f"Created Booking ID: {booking_id}, Display ID: {display_id}")
    
    # Verify exactly 1 booking exists in the database
    count_after_1 = db.query(Booking).filter(Booking.external_id == "TEST-DUP-123").count()
    print(f"Bookings count in DB: {count_after_1}")
    assert count_after_1 == 1, f"Expected exactly 1 booking, found {count_after_1}"
    
    # 2. Send the second webhook call with identical bookingID (Duplicate Booking)
    print("\n--- TEST STEP 2: Sending identical duplicate 'book' webhook request ---")
    response_2 = client.post("/api/channel-manager/webhook", json=mock_payload, headers=headers)
    
    assert response_2.status_code == 200, f"Expected 200, got {response_2.status_code}"
    res_data_2 = response_2.json()
    print("Response 2:", res_data_2)
    
    # According to our logic, it should route to _handle_modify_booking, which returns {"success": True, "message": "Modified"}
    assert res_data_2.get("success") is True, "Duplicate booking request should return success"
    assert res_data_2.get("message") == "Modified", f"Expected message 'Modified' because of modify-routing, got '{res_data_2.get('message')}'"
    
    # Verify that still exactly 1 booking exists in the database (NO DUPLICATE WAS CREATED!)
    count_after_2 = db.query(Booking).filter(Booking.external_id == "TEST-DUP-123").count()
    print(f"Bookings count in DB after duplicate request: {count_after_2}")
    assert count_after_2 == 1, f"CRITICAL FAILURE: Duplicate booking was created! Found {count_after_2} bookings instead of 1."
    
    print("\n[OK] SUCCESS: Duplicate prevention system verified successfully! Duplicate routed to modify and no duplicates created.")
    
finally:
    # Cleanup after test
    print("\nPost-test cleanup: deleting test booking 'TEST-DUP-123'...")
    db.query(Booking).filter(Booking.external_id == "TEST-DUP-123").delete()
    db.commit()
    db.close()
