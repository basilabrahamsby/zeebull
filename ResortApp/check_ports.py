
import requests

for port in [8011, 8012, 8000, 8013]:
    try:
        r = requests.get(f"http://localhost:{port}/health", timeout=2)
        print(f"Port {port}: Status {r.status_code}, Body {r.text}")
    except Exception:
        print(f"Port {port}: Connection Refused")
