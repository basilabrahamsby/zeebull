import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import os

db_url = "postgresql://postgres:qwerty123@localhost:5432/postgres"
conn = psycopg2.connect(db_url)
conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
cursor = conn.cursor()

try:
    cursor.execute("SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'zeebull' AND pid <> pg_backend_pid();")
    print("Terminated other connections.")
except Exception as e:
    print(e)

try:
    cursor.execute("DROP DATABASE IF EXISTS zeebull;")
    print("Dropped database zeebull.")
except Exception as e:
    print(e)

try:
    cursor.execute("CREATE DATABASE zeebull;")
    print("Created database zeebull.")
except Exception as e:
    print(e)

cursor.close()
conn.close()
