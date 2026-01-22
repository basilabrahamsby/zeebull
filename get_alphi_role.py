from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.user import User
import os
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"

engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

user = session.query(User).filter(User.name.ilike('%alphi%')).first()
if user:
    print(f"USER_NAME={user.name}")
    print(f"ROLE_NAME={user.role.name if user.role else 'None'}")
else:
    print("USER_NOT_FOUND")
