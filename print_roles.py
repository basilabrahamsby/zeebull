from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models.user import Role
import os

DATABASE_URL = "postgresql://orchid_user:admin123@localhost/orchid_resort"
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

for r in session.query(Role).all():
    print(f"{r.id} | {r.name}")
