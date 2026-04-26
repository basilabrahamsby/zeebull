import sys
import os
sys.path.append(os.path.abspath("ResortApp"))
from app.database import SessionLocal
from app.models.branch import Branch

db = SessionLocal()
branch = db.query(Branch).filter(Branch.id == 1).first()
if branch:
    branch.name = "Orchid"
    branch.code = "ORCHID"
    db.commit()
    print("Branch 1 renamed to Orchid.")
else:
    print("Branch 1 not found.")
