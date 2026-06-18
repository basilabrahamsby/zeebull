import os
import requests
from requests.auth import HTTPBasicAuth
from dotenv import load_dotenv

# Load .env explicitly
load_dotenv()

AIOSELL_ACTIVE = os.getenv("AIOSELL_ACTIVE", "false").lower() == "true"
HOTEL_CODE = os.getenv("AIOSELL_HOTEL_CODE")
PARTNER_ID = os.getenv("AIOSELL_PARTNER_ID")
AIOSELL_API_URL = os.getenv("AIOSELL_API_URL", "https://live.aiosell.com/api/v2/cm/update")
USERNAME = os.getenv("AIOSELL_USERNAME")
PASSWORD = os.getenv("AIOSELL_PASSWORD")

URL = f"{AIOSELL_API_URL}/{PARTNER_ID}"

print("--- AIOSELL API CREDENTIALS TEST (NO DATABASE) ---")
print(f"ACTIVE: {AIOSELL_ACTIVE}")
print(f"HOTEL_CODE: {HOTEL_CODE}")
print(f"PARTNER_ID: {PARTNER_ID}")
print(f"API_URL: {URL}")
print(f"USERNAME: {USERNAME}")
print(f"PASSWORD: {'******' if PASSWORD else 'MISSING'}")

if not HOTEL_CODE or not PARTNER_ID or not USERNAME or not PASSWORD:
    print("\nERROR: Missing one or more required AIOSELL environment variables.")
    exit(1)

# Dummy payload for a test room
payload = {
    "hotelCode": HOTEL_CODE,
    "updates": [
        {
            "startDate": "2026-06-01",
            "endDate": "2026-06-01",
            "rooms": [
                {
                    "roomCode": "TEST-CONNECTION",
                    "available": 1
                }
            ]
        }
    ]
}

print("\nSending test inventory push to Aiosell...")
try:
    response = requests.post(
        URL,
        json=payload,
        auth=HTTPBasicAuth(USERNAME, PASSWORD),
        headers={"Content-Type": "application/json", "Accept": "application/json"},
        timeout=15
    )
    
    print(f"HTTP Status Code: {response.status_code}")
    
    if response.status_code == 401:
        print("RESULT: AUTHENTICATION FAILED (401 Unauthorized). Check your Username and Password.")
    elif response.status_code == 403:
        print("RESULT: FORBIDDEN (403). Check your Partner ID and Hotel Code permissions.")
    elif response.status_code == 404:
        print("RESULT: NOT FOUND (404). Check your Partner ID and API URL.")
    else:
        try:
            resp_json = response.json()
            print(f"Response Body: {resp_json}")
            if resp_json.get("success"):
                print("\nRESULT: SUCCESS! Your credentials and connection are working.")
            else:
                message = resp_json.get("message", "Unknown error")
                print(f"\nRESULT: API REJECTED REQUEST, but Auth likely worked. Message: {message}")
                if "hotel" in message.lower() or "code" in message.lower():
                    print("Hint: Check if HOTEL_CODE is correct.")
        except Exception as e:
            print(f"Could not parse JSON response: {e}")
            print(f"Raw response: {response.text}")

except Exception as e:
    print(f"\nCONNECTION ERROR: {e}")
