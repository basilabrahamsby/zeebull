
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
from app.models.inventory import WasteLog, InventoryItem

db = SessionLocal()
logs = db.query(WasteLog).order_by(WasteLog.id.desc()).limit(10).all()
result = []
for l in logs:
    item = db.query(InventoryItem).filter(InventoryItem.id == l.item_id).first()
    result.append({
        "id": l.id,
        "log_number": l.log_number,
        "item_name": item.name if item else "Unknown",
        "notes": l.notes,
        "reason_code": l.reason_code,
        "action_taken": l.action_taken
    })

print(json.dumps(result, indent=2, default=default_json))
db.close()
