from app.utils.auth import get_db
from app.api.dashboard import get_pnl
from datetime import date

db = next(get_db())

print("Testing get_pnl...")
try:
    result = get_pnl(period="month", db=db, current_user={})
    print("PNL Result:", result)
except Exception as e:
    print("PNL Failed:")
    import traceback
    traceback.print_exc()
