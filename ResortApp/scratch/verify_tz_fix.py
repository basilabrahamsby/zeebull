import os
import sys
sys.path.append(os.getcwd())

print("Testing Python import integrity...")
try:
    from app.utils import date_utils
    print("[SUCCESS] Successfully imported app.utils.date_utils")
    
    # Test format_iso_z behavior
    from datetime import datetime, timezone, timedelta
    now_naive = datetime.now()
    now_aware = datetime.now(timezone.utc)
    
    formatted_naive = date_utils.format_iso_z(now_naive)
    formatted_aware = date_utils.format_iso_z(now_aware)
    
    print(f"  Naive input: {now_naive} -> Formatted: {formatted_naive}")
    print(f"  Aware input: {now_aware} -> Formatted: {formatted_aware}")
    
    assert "Z" not in formatted_naive, "Z suffix should not be appended to naive dates!"
    assert "Z" not in formatted_aware, "Z suffix should not be appended to aware dates!"
    
    from app.curd import foodorder
    print("[SUCCESS] Successfully imported app.curd.foodorder")
    
    # Test foodorder.get_ist_now()
    ist_now = foodorder.get_ist_now()
    print(f"  get_ist_now(): {ist_now} (Type: {type(ist_now)}, tzinfo: {ist_now.tzinfo})")
    assert ist_now.tzinfo is None, "get_ist_now should return a naive datetime!"
    
    from app.utils import food_pricing
    print("[SUCCESS] Successfully imported app.utils.food_pricing")
    
    from app.utils import food_scheduler
    print("[SUCCESS] Successfully imported app.utils.food_scheduler")
    
    from app.api import service_request
    print("[SUCCESS] Successfully imported app.api.service_request")

    print("\nALL BACKEND TIMEZONE INTEGRITY CHECKS PASSED SUCCESSFULLY! [OK]")

except Exception as e:
    print(f"\n[ERROR] Verification Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
