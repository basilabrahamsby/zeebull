from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.employee import Employee
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

e = session.query(Employee).filter(Employee.id == 4).first()
if e:
    print(f"ID={e.id}")
    print(f"NAME={e.name}")
    print(f"UID={e.user_id}")
else:
    print("NOT_FOUND")
