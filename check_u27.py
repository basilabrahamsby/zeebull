from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.user import User
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

u = session.query(User).filter(User.id == 27).first()
if u:
    print(f"UID={u.id}")
    print(f"NAME={u.name}")
    print(f"EMAIL={u.email}")
else:
    print("NOT_FOUND")
