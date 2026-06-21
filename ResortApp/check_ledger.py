import sys
import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
sys.path.append('D:\\Zeebull\\ResortApp')
from app.models.account import AccountLedger

engine = create_engine('postgresql://postgres:qwerty123@localhost:5432/zeebull')
Session = sessionmaker(bind=engine)
session = Session()

ledger = session.query(AccountLedger).filter(AccountLedger.id == 47).first()
if ledger:
    print(f"Ledger 47 exists. branch_id={ledger.branch_id}, is_active={ledger.is_active}, name={ledger.name}")
else:
    print("Ledger 47 not found")
