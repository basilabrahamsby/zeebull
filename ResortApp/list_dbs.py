import os
from sqlalchemy import create_engine, text

# Connect to 'postgres' db to list others
db_url = "postgresql://postgres:qwerty@localhost:5432/postgres"
engine = create_engine(db_url)

with engine.connect() as conn:
    dbs = conn.execute(text("SELECT datname FROM pg_database WHERE datistemplate = false")).fetchall()
    print("Databases:")
    for db in dbs:
        print(db.datname)
