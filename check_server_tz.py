try:
    import pytz
    import datetime
    ist = pytz.timezone('Asia/Kolkata')
    print(f"IST_TIME: {datetime.datetime.now(ist)}")
except Exception as e:
    print(f"ERROR: {e}")
