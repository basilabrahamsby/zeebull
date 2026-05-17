from app.database import SessionLocal
from app.api.inventory import get_transactions
from app.models.user import User

db = SessionLocal()
try:
    u = db.query(User).filter(User.is_superadmin == True).first()
    if not u:
        u = db.query(User).first()
    
    res = get_transactions(
        skip=0,
        limit=100,
        db=db,
        current_user=u,
        branch_id=1
    )
    print(f"Total transactions returned by API: {len(res)}")
    found = False
    for t in res:
        tid = t.get('id') if isinstance(t, dict) else getattr(t, 'id', None)
        if tid == 256:
            found = True
            ttype = t.get('transaction_type') if isinstance(t, dict) else getattr(t, 'transaction_type', None)
            tqty = t.get('quantity') if isinstance(t, dict) else getattr(t, 'quantity', None)
            print(f"Found ID 256 in API response! Type: {ttype}, Qty: {tqty}")
    if not found:
        print("ID 256 was NOT found in the API response!")
finally:
    db.close()
