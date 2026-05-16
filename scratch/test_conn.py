import psycopg2
try:
    conn = psycopg2.connect("host=localhost dbname=zeebull user=postgres password=qwerty123 port=5432")
    print("Connected successfully")
    conn.close()
except Exception as e:
    print(f"Error: {e}")
