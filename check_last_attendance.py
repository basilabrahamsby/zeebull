import sys
import os
sys.path.append(os.path.join(os.getcwd(), 'ResortApp'))
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.employee import WorkingLog

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

log = session.query(WorkingLog).order_by(WorkingLog.id.desc()).first()

if log:
    print(f"ID: {log.id}")
    print(f"Date: {log.date}")
    print(f"Check In Time: {log.check_in_time}")
    print(f"Check Out Time: {log.check_out_time}")
    print(f"Location: {log.location}")
else:
    print("No logs found.")
