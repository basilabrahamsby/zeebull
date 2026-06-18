import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv('.env')
db_url = os.getenv('DATABASE_URL')

if db_url.startswith('postgresql+psycopg2://'):
    db_url = db_url.replace('postgresql+psycopg2://', 'postgresql://')

engine = create_engine(db_url)

with engine.connect() as conn:
    sql = text("""
        SELECT e.id, e.name, e.role, e.salary, u.email 
        FROM employees e 
        JOIN users u ON e.user_id = u.id
    """)
    employees = conn.execute(sql).fetchall()
    print("Employees in Database:")
    for e in employees:
        print(f"ID: {e.id}, Name: {e.name}, Role: {e.role}, Salary: {e.salary}, Email: {e.email}")
