
import requests
import json

BASE_URL = "http://127.0.0.1:8011"
AUTH_URL = f"{BASE_URL}/api/auth/login"
TEST_URL = f"{BASE_URL}/api/rooms/test"

def reproduce_multipart():
    print("--- Authenticating ---")
    token = requests.post(AUTH_URL, json={"email": "admin", "password": "admin123"}).json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    print("\n--- Sending MULTIPART POST request ---")
    data = {
        "number": "101",
        "type": "Deluxe",
        "price": "1300",
        "status": "Available",
        "adults": "2",
        "children": "2",
        "air_conditioning": "false",
        "wifi": "true", 
        # ... other bools
    }
    
    # Passing 'files' triggers multipart/form-data.
    # We pass 'image' as None to simulate missing file? 
    # Or just don't pass 'image' in files?
    # If the browser doesn't append 'image', it's not in the body.
    # So we just send 'data' and force requests to use multipart?
    # Sending `files` with empty dict doesn't force multipart in older requests?
    # Hack: send a dummy file that isn't 'image' just to trigger multipart?
    # OR better: use requests functionality.
    
    # Actually, if we pass 'files', data fields are sent as parts.
    # We won't include 'image' in data or files.
    
    # To force multipart without a real file:
    # requests doesn't make this super easy without at least one file-like object.
    # But wait, CreateRooms.jsx sends WITHOUT image if null.
    
    # Let's try sending NO files, but ensure header is multipart? 
    # requests calculates boundary automatically ONLY if files arg is present.
    
    # Let's try explicit None for image in files?
    # files = {'image': (None, None)} ??
    
    try:
        # Use an empty files dict? 
        # Or maybe the browser IS sending 'image' as empty binary?
        # CreateRooms.jsx: "if (form.image) formData.append..." -> So it's NOT sent.
        
        # So we simply need to send `data` as multipart.
        # How to do that in requests? 
        # workaround:
        # files = {} # doesn't work
        # We can construct MultipartEncoder (toolbelt) or...
        
        # Let's just try sending a dummy file that won't be read by backend.
        # files={'_dummy': ('dummy', 'dummy')}
        
        files = {} 
        
        # NOTE: If we use `files` argument, `data` is sent as form-fields.
        # To simulate "no image file", we just don't put 'image' in files.
        # But we need requests to use multipart.
        
        # Let's try simulating exactly what might happen if user selected a file then cancelled? 
        # No, user says "failed to load resource" immediately.
        
        # Let's try putting 'image' explicitly as None in files?
        # files = {'image': (None, '', 'application/octet-stream')} ?
        
        # If I can't replicate 422 with requests, I can't check the message.
        
        resp = requests.post(TEST_URL, data=data, headers=headers) 
        # ^ This sends application/x-www-form-urlencoded. And it worked (200).
        
        # What if the backend strictly requires multipart but received urlencoded?
        # FastAPI handles both for Form().
        
        # So why did User fail?
        # User dashboard definitely sends multipart (FormData).
        # Maybe FastAPI validation fails on multipart parsing for some reason?
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    reproduce_multipart()
