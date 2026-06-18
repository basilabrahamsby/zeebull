import os
import sys
import psycopg2
from dotenv import load_dotenv

# Load database URL from .env
load_dotenv()
db_url = os.getenv('DATABASE_URL')

if not db_url:
    print("Error: DATABASE_URL not found in .env")
    sys.exit(1)

# Clean up SQLAlchemy prefix if present
if db_url.startswith('postgresql+psycopg2://'):
    db_url = db_url.replace('postgresql+psycopg2://', 'postgresql://')

try:
    conn = psycopg2.connect(db_url)
    conn.autocommit = True
    cur = conn.cursor()
    print("Successfully connected to the database.")
    print("Type your SQL query and press Enter. Type 'exit' or 'quit' to quit.")
    
    while True:
        try:
            query = input("SQL> ")
            if query.strip().lower() in ['exit', 'quit']:
                break
            if not query.strip():
                continue
                
            cur.execute(query)
            
            # If it's a SELECT query, print results
            if cur.description:
                columns = [desc[0] for desc in cur.description]
                results = cur.fetchall()
                print(f"\n{columns}")
                print("-" * 50)
                for row in results:
                    print(row)
                print(f"({len(results)} rows)\n")
            else:
                print("Query executed successfully.\n")
                
        except Exception as e:
            print(f"Error executing query: {e}\n")
            
except Exception as e:
    print(f"Connection failed: {e}")
finally:
    if 'conn' in locals() and conn:
        conn.close()
