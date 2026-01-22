import json
import psycopg2

conn = psycopg2.connect("postgresql://postgres:qwerty123@localhost/orchid_resort")
cur = conn.cursor()
cur.execute("SELECT inventory_data FROM checkout_requests WHERE id = 1")
row = cur.fetchone()
if row and row[0]:
    print(json.dumps(row[0], indent=2))
else:
    print("No data")
conn.close()
