from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.user import User
from app.models.employee import Employee
import os
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"

engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

users = session.query(User).all()
print("-" * 30)
for user in users:
    try:
        username = user.name or ""
        if 'alphi' in username.lower() or 'dayon' in username.lower():
            print(f"User: {user.name}")
            role_name = user.role.name if user.role else 'None'
            print(f"Role: {role_name}")
            if user.employee:
                print(f"Employee Name: {user.employee.name}, ID: {user.employee.id}")
            else:
                print("No linked employee")
            print("-" * 30)
    except Exception as e:
        print(f"Error printing user {user.id if user else '?'}: {e}")
