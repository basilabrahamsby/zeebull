from app.database import SessionLocal
from sqlalchemy import text

db = SessionLocal()
try:
    print("=== INSPECTING CURRENT SCHEMA ===")
    
    # 1. Check if bookings has gst_number
    res = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'gst_number'")).first()
    print("bookings has gst_number:", res is not None)
    
    # 2. Check if checkouts has gst_number
    res = db.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name = 'checkouts' AND column_name = 'gst_number'")).first()
    print("checkouts has gst_number:", res is not None)
    
    # 3. Check if account_groups has _name_branch_uc constraint
    res = db.execute(text("""
        SELECT conname FROM pg_constraint 
        WHERE conname = '_name_branch_uc' OR conname = '_ledger_name_branch_uc'
    """)).all()
    print("Found constraints:", [r[0] for r in res])
    
    # 4. Check current alembic version in DB
    res = db.execute(text("SELECT version_num FROM alembic_version")).all()
    print("Alembic version in DB:", [r[0] for r in res])

except Exception as e:
    print("Error:", e)
finally:
    db.close()
