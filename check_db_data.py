import sys
import os
sys.path.append(os.getcwd())
from app.database import SessionLocal
from app.models.inventory import PurchaseMaster
from app.models.expense import Expense
db = SessionLocal()
print('--- Purchases ---')
purchases = db.query(PurchaseMaster).all()
for p in purchases: print(f'ID: {p.id}, Vendor: {p.vendor_id}, Amount: {p.total_amount}, Status: {p.status}')
print('\n--- Expenses ---')
expenses = db.query(Expense).all()
for e in expenses: print(f'ID: {e.id}, Amount: {e.amount}, Vendor: {e.vendor_id}')
from app.models.inventory import Vendor
print('\n--- Vendors ---')
vendors = db.query(Vendor).all()
for v in vendors: print(f'ID: {v.id}, Name: {v.name}')
