import requests
import json

BASE_URL = "http://localhost:8011/api"
LOGIN_URL = f"{BASE_URL}/auth/login"
ROOMS_URL = f"{BASE_URL}/rooms/"
BOOKINGS_URL = f"{BASE_URL}/bookings?skip=0&limit=50"

CREDS = {
    "email": "admin@orchid.com",
    "password": "admin123"
}

def test_rooms_and_bookings():
    print("=" * 80)
    print("TESTING ROOMS AND BOOKINGS API")
    print("=" * 80)
    
    # Login
    print("\n1. Logging in...")
    try:
        resp = requests.post(LOGIN_URL, json=CREDS)
        if resp.status_code != 200:
            print(f"Login failed: {resp.status_code} - {resp.text}")
            return
        token = resp.json().get("access_token")
        print(f"✓ Login successful")
    except Exception as e:
        print(f"Connection failed: {e}")
        return
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Get rooms
    print("\n2. Fetching rooms...")
    rooms_resp = requests.get(ROOMS_URL, headers=headers)
    rooms = rooms_resp.json()
    
    print(f"✓ Total rooms: {len(rooms)}")
    print("\nRooms 100, 101, 102, 103:")
    for room in rooms:
        if room['number'] in ['100', '101', '102', '103']:
            print(f"  - Room {room['number']}: ID={room['id']}, Type={room['type']}, Status={room['status']}")
    
    # Get bookings
    print("\n3. Fetching bookings...")
    bookings_resp = requests.get(BOOKINGS_URL, headers=headers)
    bookings_data = bookings_resp.json()
    bookings = bookings_data.get('bookings', [])
    
    print(f"✓ Total bookings: {len(bookings)}")
    
    # Check which bookings have rooms 100, 101, 102
    print("\n4. Checking bookings for rooms 100, 101, 102:")
    target_rooms = ['100', '101', '102']
    
    for booking in bookings:
        if booking.get('rooms'):
            booking_room_numbers = []
            for r in booking['rooms']:
                # Handle both regular and package bookings
                room_num = r.get('number') or r.get('room', {}).get('number')
                if room_num:
                    booking_room_numbers.append(room_num)
            
            # Check if any target rooms are in this booking
            if any(rn in target_rooms for rn in booking_room_numbers):
                print(f"\n  Booking ID: {booking['id']}")
                print(f"    Status: {booking['status']}")
                print(f"    Is Package: {booking.get('is_package', False)}")
                print(f"    Check-in: {booking['check_in']}")
                print(f"    Check-out: {booking['check_out']}")
                print(f"    Rooms: {booking_room_numbers}")
                print(f"    Guest: {booking['guest_name']}")
    
    print("\n" + "=" * 80)

if __name__ == "__main__":
    test_rooms_and_bookings()
