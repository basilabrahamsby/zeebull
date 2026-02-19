
import sys
import os
import json
from datetime import date, datetime

def default_json(obj):
    if isinstance(obj, (date, datetime)):
        return obj.isoformat()
    return str(obj)

current_dir = os.getcwd()
if current_dir not in sys.path:
    sys.path.append(current_dir)

from app.database import SessionLocal
from app.models.checkout import CheckoutRequest

db = SessionLocal()
last_req = db.query(CheckoutRequest).order_by(CheckoutRequest.id.desc()).first()
if last_req:
    print(json.dumps({
        "id": last_req.id,
        "status": last_req.status,
        "inventory_data": last_req.inventory_data
    }, indent=2, default=default_json))
else:
    print("No checkout request found")
db.close()
