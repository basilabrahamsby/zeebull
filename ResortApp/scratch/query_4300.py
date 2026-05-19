import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

db_url = os.getenv("DATABASE_URL")
if db_url.startswith("postgresql+psycopg2://"):
    db_url = db_url.replace("postgresql+psycopg2://", "postgresql://", 1)

tables = ["checkouts", "bookings", "package_bookings", "food_orders", "payments", "checkout_payments"]

try:
    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    
    for table in tables:
        print(f"\n=================== SEARCHING TABLE: {table.upper()} ===================")
        # Get column names
        cur.execute(f"SELECT column_name, data_type FROM information_schema.columns WHERE table_name='{table}';")
        cols = cur.fetchall()
        col_names = [c[0] for c in cols]
        
        # Build search query
        conditions = []
        for name, dtype in cols:
            if dtype in ('integer', 'double precision', 'real', 'numeric'):
                conditions.append(f"\"{name}\" = 4300")
                conditions.append(f"\"{name}\" = 4300.0")
            elif dtype in ('character varying', 'text'):
                conditions.append(f"\"{name}\" LIKE '%4300%'")
                
        if conditions:
            query = f"SELECT * FROM \"{table}\" WHERE " + " OR ".join(conditions) + ";"
            try:
                cur.execute(query)
                rows = cur.fetchall()
                if rows:
                    print(f"Columns: {col_names}")
                    print(f"Found {len(rows)} matching rows:")
                    for row in rows:
                        print(row)
                else:
                    print("No matches.")
            except Exception as e:
                print(f"Error querying {table}: {e}")
        else:
            print("No searchable columns.")
            
    cur.close()
    conn.close()
except Exception as e:
    print(f"Error: {e}")
