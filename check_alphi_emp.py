from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.user import User
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

user = session.query(User).filter(User.name.ilike('%alphi%')).first()
if user:
    print(f"NAME={user.name}")
    print(f"ROLE={user.role.name if user.role else 'None'}")
    if user.employee:
        print(f"EMP_ID={user.employee.id}")
        print(f"EMP_NAME={user.employee.name}")
    else:
        print("NO_EMPLOYEE")
else:
    print("USER_NOT_FOUND")
