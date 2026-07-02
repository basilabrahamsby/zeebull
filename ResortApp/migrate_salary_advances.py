"""
Migration: Create salary_advances table
Run this once on the server to create the table.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.database import engine, Base
from app.models.salary_advance import SalaryAdvance

print("Creating salary_advances table...")
Base.metadata.create_all(bind=engine, tables=[SalaryAdvance.__table__])
print("SUCCESS: salary_advances table created successfully.")
