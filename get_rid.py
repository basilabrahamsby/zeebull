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
    print(f"UID={user.id}")
    print(f"RID={user.role_id}")
    print(f"RNAME={user.role.name if user.role else 'None'}")
else:
    print("NOT_FOUND")
